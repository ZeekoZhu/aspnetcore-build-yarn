#load ".fake/build.fsx/intellisense.fsx"
#if !FAKE
  #r "Facades/netstandard"
#endif
open System
open System.IO
open System.Text.RegularExpressions
open Fake.Core
open Fake.Core.TargetOperators
open Fake.Tools
open CommandLine
open Nett
open Fake.MyFakeTools
open System.Net.Http

// ----------------------
// Var
// ----------------------

let BuildParams = "BuildParams"


// ----------------------
// Utils
// ----------------------

let httpClient = new HttpClient()

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
          [<Option('v', Required = true)>] Version: string
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

    let getBuildParams (version: string) (name: string) =
        let spec = Toml.ReadFile<ImageSpec>(sprintf "./%s.spec.toml" version)
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

module BuildInfo =
    open FSharp.Control.Tasks.V2
    [<NoComparison>]
    type BuildInfoOptions =
        { [<Option('d', "dotnet", Required = true)>] DotnetVersions: string seq
        }
    let parseDotnetSdkInfo str =
        let versionRegex = Regex("""^ENV DOTNET_SDK_VERSION (.+)$""", RegexOptions.Multiline)
        let version = versionRegex.Matches(str).[0].Groups.[1].Value
        let checksumRegex = Regex("""dotnet_sha512='(\w+)' \\$""", RegexOptions.Multiline)
        let checksum = checksumRegex.Matches(str).[0].Groups.[1].Value
        version, checksum

    let parseAspNetInfo str =
        let versionRegex = Regex("^ENV ASPNETCORE_VERSION (.+)$", RegexOptions.Multiline)
        let version = versionRegex.Matches(str).[0].Groups.[1].Value
        let checksumRegex = Regex("""aspnetcore_sha512='(\w+)'""", RegexOptions.Multiline)
        let checksum = checksumRegex.Matches(str).[0].Groups.[1].Value
        version, checksum

    let parseNodejsInfo downloadPage =
        let versionRegex = Regex("""<strong>(.+)<\/strong>""", RegexOptions.Multiline)
        let version = versionRegex.Matches(downloadPage).[0].Groups.[1].Value
        let checksums =
            task {
                return! httpClient.GetStringAsync(sprintf "https://nodejs.org/dist/v%s/SHASUMS256.txt.asc" version)
            } |> Async.AwaitTask |> Async.RunSynchronously
        let checksumRegex = Regex("""^(\w+)\s+node-v.+linux-x64\.tar\.gz$""", RegexOptions.Multiline)
        let checksum = checksumRegex.Matches(checksums).[0].Groups.[1].Value
        version, checksum

    let getDepsInfo (options: BuildInfoOptions) =
        let sdkInfoTask version =
            task {
                let! resp = httpClient.GetStringAsync(sprintf "https://raw.githubusercontent.com/dotnet/dotnet-docker/master/%s/sdk/alpine3.9/amd64/Dockerfile" version)
                let result = "Dotnet SDK", (parseDotnetSdkInfo resp)
                return result
            } |> Async.AwaitTask
        let runtimeTask version =
            task {
                let! resp = httpClient.GetStringAsync(sprintf "https://raw.githubusercontent.com/dotnet/dotnet-docker/master/%s/aspnet/alpine3.9/amd64/Dockerfile" version)
                let result = "AspNetCore Runtime", (parseAspNetInfo resp)
                return result
            } |> Async.AwaitTask
        let nodejsTask =
            task {
                let! resp = httpClient.GetStringAsync("https://nodejs.org/en/download/current/")
                let result = "Node.js", (parseNodejsInfo resp)
                return result
            } |> Async.AwaitTask
        let tasks =
            seq {
                for v in options.DotnetVersions do
                    yield sdkInfoTask v
                    yield runtimeTask v
                yield nodejsTask
            }
        Async.Parallel tasks
        |> Async.RunSynchronously
        |> Seq.iter (fun (name, (version, checksum)) ->
                Trace.logfn "%s:\nVersion: %s\nChecksum: %s" name version checksum
            )



// ----------------------
// Targets
// ----------------------


 
let ciBuild (p: Docker.BuildOptions) =
    let buildParams = Docker.getBuildParams p.Version p.Tag
    let buildOptions = { p with Tag = buildParams.TestImage }
    Docker.build buildOptions
    FakeVar.set BuildParams buildParams

Target.useTriggerCI ()

Target.create "CI:Build" (fun p -> handleCli p.Context.Arguments ciBuild)

Target.create "CI:Test" (fun _ -> Docker.testImage())

Target.create "CI:Publish" (fun _ -> Docker.publishImage())

Target.create "update:info" (fun p ->
    handleCli p.Context.Arguments BuildInfo.getDepsInfo
)

Target.create "CI" ignore

"CI:Build" ==> "CI:Test" ==> "CI:Publish" ==> "CI"

Target.create "Empty" ignore

Target.runOrDefaultWithArguments "Empty"
