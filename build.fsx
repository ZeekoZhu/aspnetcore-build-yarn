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

module TriggerCI =
    type TriggerCIOptions =
        { [<Option('v', "version", Required = true)>] Version: string
          [<Option('l', "latest", Default = false)>] IsProd: bool
        }

    let ensureWorkspaceClean () =
        let isEmpty = Git.Information.isCleanWorkingCopy "./"
        if not isEmpty then failwith "Workspace is not clean"
        isEmpty

    let validateVersion (options: TriggerCIOptions) =
        let newTag =
            if options.IsProd then options.Version
            else options.Version + "-" + Git.Information.getCurrentHash ()
            |> SemVer.parse
        let latestTag = getLatestTag () |> SemVer.parse
        Trace.tracefn "Latest version: %s" latestTag.AsString
        if newTag < latestTag then failwithf "Invalid version: %A < %A" newTag latestTag
        Trace.tracefn "New version: %s" newTag.AsString
        newTag

    let tagCurrent (tag) =
        Git.Branches.tag "./" tag

    let pushCommits () =
        let runCmd = Git.CommandHelper.runSimpleGitCommand "./"
        runCmd "push --all" |> ignore
        runCmd "push --tags" |> ignore

    let triggerCi (options: TriggerCIOptions) =
        Trace.logfn "%A" options
        ensureWorkspaceClean () |> ignore
        let version = validateVersion options
        tagCurrent version.AsString
        pushCommits ()
        ()

    let triggerCiCli (args: seq<string>) =
        handleCli args triggerCi

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

            let checkVersion item itemValue actualValue =
                Trace.tracefn "Q: Is %s's version %s?" item itemValue
                if itemValue <> actualValue
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

let triggerCi (p: TargetParameter) =
    TriggerCI.triggerCiCli p.Context.Arguments
 
let ciBuild (p: Docker.BuildOptions) =
    let buildParams = Docker.getBuildParams p.Tag
    let buildOptions = { p with Tag = buildParams.TestImage }
    Docker.build buildOptions
    FakeVar.set BuildParams buildParams

Target.create "TriggerCI" triggerCi

Target.create "CI:Build" (fun p -> handleCli p.Context.Arguments ciBuild)

Target.create "CI:Test" (fun _ -> Docker.testImage())

Target.create "CI:Publish" (fun _ -> Docker.publishImage())

Target.create "CI" ignore

"CI:Build" ==> "CI:Test" ==> "CI:Publish" ==> "CI"

Target.create "Empty" ignore

Target.runOrDefaultWithArguments "Empty"
