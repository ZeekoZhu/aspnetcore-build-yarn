#load ".fake/build.fsx/intellisense.fsx"
#if !FAKE
  #r "Facades/netstandard"
#endif
open System
open System.IO
open System.Text.RegularExpressions
open Fake.Core
open Fake.DotNet
open Fake.IO
open Fake.IO.FileSystemOperators
open Fake.IO.Globbing.Operators
open Fake.Core.TargetOperators
open Fake.Tools
open CommandLine
open CommandLine.Text
open Nett
open Fake.MyFakeTools

// ----------------------
// Var
// ----------------------

let BuildParams = "BuildParams"


// ----------------------
// Utils
// ----------------------

let showOutput =
    CreateProcess.redirectOutput
    >> (CreateProcess.withOutputEventsNotNull Trace.log Trace.traceError)
    >> CreateProcess.ensureExitCode

let runCmd file args =
    CreateProcess.fromRawCommand file args
    |> showOutput
    |> Proc.run
    |> ignore

let runCmdAndReturn file args =
    let result =
        CreateProcess.fromRawCommand file args
        |> showOutput
        |> Proc.run
    result.Result.Output

let dockerCmd (subCmd: string) (args: string list) = runCmd "docker" (subCmd::args)

let runGitCmd command =
    let (success, stdout, stderr) = Git.CommandHelper.runGitCommand "./" command
    if success then stdout |> List.head
    else failwith stderr

let getLatestTag () =
    let revListResult =
        runGitCmd "rev-list --tags --max-count=1"
    let tagName =
        runGitCmd (sprintf "describe --tags %s" revListResult)
    tagName

let handleCli<'t> (args: seq<string>) (fn: 't -> unit) =
    let parseResult =
        Parser.Default.ParseArguments<'t> args
    match parseResult with
    | :? Parsed<'t> as parsed -> fn parsed.Value
    | :? NotParsed<'t> as notParsed ->
        failwithf "Invalid: %A, Errors: %A" args notParsed.Errors
    | _ -> failwith "Invalid parser result"

// ----------------------
// Command Line Interface
// ----------------------
module Docker =
    open System.IO

    type BuildOptions =
        { [<Option('t', Required = true)>] Tag: string
          [<Option('f', Required = true)>] Dockerfile: string
          [<Option('c', Required = true)>] ContextPath: string
        }

    let build (options: BuildOptions) =
        dockerCmd "build"
            [ "-t"; options.Tag; "-f"; options.Dockerfile; options.ContextPath ]

    [<CLIMutable>]
    type ImageSpecItem =
        { Name: string
          TestImage: string
          Dotnet: string
          Node: string
          Yarn: string
          Sdk: bool
          Suffix: string
          Latest: bool
          SkipTest: bool
          Tag: string
        }

    [<CLIMutable>]
    type ImageSpec =
        { Images: ImageSpecItem [] }

    let getBuildParams (name: string) =
        let spec = Toml.ReadFile<ImageSpec>("./spec.toml")
        spec.Images |> Seq.find (fun x -> x.Name = name)

    let testImage () =
        let imageSpec = FakeVar.getOrFail<ImageSpecItem> BuildParams
        if imageSpec.SkipTest then ()
        else
            let dockerRunRm args =
                runCmdAndReturn "docker" (["run"; "--rm"; imageSpec.TestImage; ] @ args)

            let checkVersion item itemValue (actualValue: string) =
                Trace.tracefn "Q: Is %s's version %s ?" item itemValue
                if itemValue.Trim() <> actualValue.Trim()
                then
                    Trace.traceErrorfn "A: No, %s's version is %s!" item actualValue
                    failwithf "Test %s failed" item
                else Trace.tracefn "A: Yes!"

            let dotnetVersion =
                if imageSpec.Sdk
                then dockerRunRm ["dotnet"; "--version"]
                else
                    let reg = Regex("^  Version: (?<runtime>.*)$", RegexOptions.Multiline)
                    let result = dockerRunRm ["dotnet"; "--info"]
                    (reg.Match(result).Groups.Item "runtime").Value

            let nodeVersion = 
                dockerRunRm ["node"; "--version"]

            let yarnVersion =
                dockerRunRm ["yarn"; "--version"]

            [ ("dotnet", dotnetVersion, imageSpec.Dotnet)
              ("node.js", nodeVersion, imageSpec.Node)
              ("yarn", yarnVersion, imageSpec.Yarn)
            ]
            |> List.iter (fun (item, actual, expected) -> checkVersion item expected actual)


    let login () =
        let dockerPwd = Environment.environVar "DOCKER_PASSWORD"
        let dockerUsr = Environment.environVar "DOCKER_USERNAME"
        let input = StreamRef.Empty
        
        let proc =
            CreateProcess.fromRawCommand
                "docker" [ "login"; "-u"; dockerUsr; "--password-stdin" ]
            |> CreateProcess.withStandardInput (CreatePipe input)
            |> showOutput
            |> Proc.start
        use inputWriter = new StreamWriter(input.Value)
        inputWriter.WriteLine dockerPwd
        inputWriter.Close()
        proc.Wait()

    let publishImage () =
        let spec = FakeVar.getOrFail<ImageSpecItem> BuildParams
        login ()
        let version = SemVer.parse spec.Dotnet
        let major = string version.Major
        let minor = major + "." + string version.Minor
        let patch = minor + "." + string version.Patch
        seq {
            yield major
            yield minor
            yield patch
            if spec.Latest then yield "latest"
        }
        |> Seq.map (fun t ->
             let tag = spec.Tag + ":" + t
             if String.isNullOrEmpty spec.Suffix then tag
             else tag + "-" + spec.Suffix
           )
        |> Seq.iter (fun t ->
            Trace.tracefn "Pushing %s" t
            dockerCmd "tag" [ spec.TestImage; t ]
            dockerCmd "push" [ t ]
           )

// ----------------------
// Targets
// ----------------------


 
let ciBuild (p: Docker.BuildOptions) =
    let buildParams = Docker.getBuildParams p.Tag
    let buildOptions = { p with Tag = buildParams.TestImage }
    Docker.build buildOptions
    FakeVar.set BuildParams buildParams

Target.useTriggerCI ()

Target.create "CI:Build" (fun p -> handleCli p.Context.Arguments ciBuild)

Target.create "CI:Test" (fun _ -> Docker.testImage())

Target.create "CI:Publish" (fun _ -> Docker.publishImage())

Target.create "CI" ignore

"CI:Build" ==> "CI:Test" ==> "CI:Publish" ==> "CI"

Target.create "Empty" ignore

Target.runOrDefaultWithArguments "Empty"
