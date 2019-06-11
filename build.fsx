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
    if success then String.Join ("\n", stdout)
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

let gitPush () =
    let gitUsr = Environment.environVar "GITHUB_USER"
    let gitToken = Environment.environVar "GITHUB_TOKEN"
    runCmd "git" ["push"; sprintf "https://%s:%s@github.com/ZeekoZhu/aspnetcore-build-yarn" gitUsr gitToken; "HEAD:daily"]

let checkTemplateUpdate () =
    let changed =
        runGitCmd "diff HEAD~ --name-only"
    changed.Contains "daily-template/"


// ----------------------
// Command Line Interface
// ----------------------
module Docker =
    open System.IO

    type BuildOptions =
        { [<Option('t', Required = true)>] Tag: string
          [<Option('f', Required = true)>] Dockerfile: string
          [<Option('c', Required = true)>] ContextPath: string
          [<Option('s', "spec", Required = true)>] Spec: string
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
          Daily: bool
        }

    [<CLIMutable>]
    type ImageSpec =
        { Images: ImageSpecItem [] }

    let getBuildParams (specFile: string) (name: string) =
        let spec = Toml.ReadFile<ImageSpec>(specFile)
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
                    let reg = Regex("^  Microsoft.AspNetCore.App (?<runtime>.*) \\[.*\\]$", RegexOptions.Multiline)
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
        let patch = version.Original.Value
        seq {
            if not spec.Daily then
                yield major
                yield minor
                if spec.Latest then yield "latest"
            yield patch
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
    
    let ciBuild (p: BuildOptions) =
        let buildParams = getBuildParams p.Spec p.Tag
        let buildOptions = { p with Tag = buildParams.TestImage }
        build buildOptions
        FakeVar.set BuildParams buildParams

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

    let parseYanrInfo downloadPage =
        let versionRegex = Regex("""releases\/tag\/v(?<version>[0-9.]+)""", RegexOptions.Multiline)
        let version = (versionRegex.Match(downloadPage).Groups.Item "version").Value
        version

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
    
    let getSdkInfoAsync version =
        task {
            let! resp = httpClient.GetStringAsync(sprintf "https://raw.githubusercontent.com/dotnet/dotnet-docker/master/%s/sdk/alpine3.9/amd64/Dockerfile" version)
            return (parseDotnetSdkInfo resp)
        } |> Async.AwaitTask
    
    let getRuntimeInfoAsync version =
        task {
            let! resp = httpClient.GetStringAsync(sprintf "https://raw.githubusercontent.com/dotnet/dotnet-docker/master/%s/aspnet/alpine3.9/amd64/Dockerfile" version)
            let result = (parseAspNetInfo resp)
            return result
        } |> Async.AwaitTask

    let getNodeJsInfoAsync () =
        task {
            let! resp = httpClient.GetStringAsync("https://nodejs.org/en/download/current/")
            let result = (parseNodejsInfo resp)
            return result
        } |> Async.AwaitTask

    let getYarnInfoAsync () =
        task {
            let! resp = httpClient.GetStringAsync("https://yarnpkg.com/en")
            return parseYanrInfo resp
        } |> Async.AwaitTask

    let getDepsInfo (options: BuildInfoOptions) =
        let sdkInfoTask version =
            task {
                let! resp = getSdkInfoAsync version
                let result = "Dotnet SDK", resp
                return result
            } |> Async.AwaitTask
        let runtimeTask version =
            task {
                let! resp = getRuntimeInfoAsync version
                let result = "AspNetCore Runtime", resp
                return result
            } |> Async.AwaitTask
        let nodejsTask =
            task {
                let! resp = getNodeJsInfoAsync ()
                let result = "Node.js", resp
                return result
            } |> Async.AwaitTask
        let yarnTask =
            task {
                let! resp = getYarnInfoAsync ()
                let result = "Yarn", (resp, "N/A")
                return result
            } |> Async.AwaitTask
        let tasks =
            seq {
                for v in options.DotnetVersions do
                    yield sdkInfoTask v
                    yield runtimeTask v
                yield nodejsTask
                yield yarnTask
            }
        Async.Parallel tasks
        |> Async.RunSynchronously
        |> Seq.iter (fun (name, (version, checksum)) ->
                Trace.logfn "%s:\nVersion: %s\nChecksum: %s" name version checksum
            )


module DailyBuild =
    open BuildInfo
    open Fake.IO
    open Fake.IO.FileSystemOperators
    open Fake.IO.Globbing.Operators
    [<CLIMutable>]
    type DailyBuildInfo =
        { NodeVersion: string
          YarnVersion: string
          NodeSHA: string
          DepsVersion: string
          AspNetCoreVersion: string
          AspNetCoreSHA: string
          AspNetImage: string
          SdkVersion: string
          SdkSHA: string
          SdkImage: string
          FetchTime: string
        }
    module Templating =
        let getAllTemplates () =
            !! "daily-template/**/*"
        let templatingFile (info: DailyBuildInfo) template =
            info.GetType()
                .GetProperties()
            |> Seq.map (fun prop -> prop.Name, (prop.GetValue(info) :?> string))
            |> Seq.fold ( fun (templ: string) (propName, value) ->
                templ.Replace( (sprintf "{{%s}}" propName), value)
            ) template
        let renderAllTemplates dotnetVersion info =
            for templ in getAllTemplates () do
                let content = File.ReadAllText templ
                let rendered = templatingFile info content
                let outputPath = templ.Replace("daily-template", "daily" </> dotnetVersion)
                Directory.ensure (Directory.GetParent(outputPath).FullName)
                File.WriteAllText (outputPath, rendered)

    let getDailyBuildInfo (dotnetVersion) =
        async {
            let! (nodeVersion, nodeSha) = getNodeJsInfoAsync ()
            let! (sdkVersion, sdkSha) = getSdkInfoAsync (dotnetVersion)
            let! (aspnetVersion, aspnetSha) = getRuntimeInfoAsync (dotnetVersion)
            let! yarnVersion = getYarnInfoAsync ()
            let depsVersion = aspnetVersion + "-daily"
            let aspnetImage = dotnetVersion
            let sdkImage = dotnetVersion
            return
                { NodeVersion = nodeVersion
                  YarnVersion = yarnVersion
                  NodeSHA = nodeSha
                  DepsVersion = depsVersion
                  AspNetCoreVersion = aspnetVersion
                  AspNetCoreSHA = aspnetSha
                  AspNetImage = aspnetImage
                  SdkSHA = sdkSha
                  SdkVersion = sdkVersion
                  SdkImage = sdkImage
                  FetchTime = DateTime.Now.ToString("O")
                }
        }

    let trackingVersions =
        File.ReadAllLines("./tracking-versions.txt")
        |> Seq.filter (fun x -> (not (String.isNullOrWhiteSpace x)))

    let getAllDailyBuildInfo () =
        let versions =
            File.ReadAllLines("./tracking-versions.txt")
            |> Seq.filter (fun x -> (not (String.isNullOrWhiteSpace x)))
        for version in versions do
            let infoFile = "daily" </> version </> "daily-build-info.toml"
            
            let info =
                getDailyBuildInfo version |> Async.RunSynchronously
            let previousInfo =
                { (File.readAsString infoFile
                    |> Toml.ReadString<DailyBuildInfo>)
                    with
                        FetchTime = info.FetchTime
                }
            if info = previousInfo then
                let skip = FakeVar.getOrFail<string list> "SkipVersions"
                FakeVar.set "SkipVersions" (version::skip)
            else
                Trace.tracefn "%A" info
                Directory.ensure ("daily" </> version)
                File.writeString false (infoFile) (Nett.Toml.WriteString info)
                Templating.renderAllTemplates version info

    let buildDailyImages (dotnetVersion) =
        let convertVersionedString (str: string) version =
            str.Replace("%s", version)
        let convertCmd (cmd: string) =
            cmd.Split([|' '|])
            |> Array.toList
        Target.run 1 "CI" (convertVersionedString "-t zeekozhu/aspnetcore-build-yarn -f daily/%s/sdk/Dockerfile -c ./daily/%s/sdk -s ./daily/%s/daily.spec.toml" dotnetVersion |> convertCmd)
        Target.run 1 "CI" (convertVersionedString "-t zeekozhu/aspnetcore-build-yarn:chromium -f daily/%s/sdk/chromium.Dockerfile -c ./daily/%s/sdk -s ./daily/%s/daily.spec.toml" dotnetVersion |> convertCmd)
        Target.run 1 "CI" (convertVersionedString "-t zeekozhu/aspnetcore-node -f daily/%s/runtime/Dockerfile -c ./daily/%s/runtime -s ./daily/%s/daily.spec.toml" dotnetVersion |> convertCmd)
        Target.run 1 "CI" (convertVersionedString "-t zeekozhu/aspnetcore-node-deps -f daily/%s/deps/Dockerfile -c ./daily/%s/deps -s ./daily/%s/daily.spec.toml" dotnetVersion |> convertCmd)
        Target.run 1 "CI" (convertVersionedString "-t zeekozhu/aspnetcore-node:alpine -f daily/%s/runtime/alpine.Dockerfile -c ./daily/%s/runtime -s ./daily/%s/daily.spec.toml" dotnetVersion |> convertCmd)
        Target.run 1 "CI" (convertVersionedString "-t zeekozhu/aspnetcore-build-yarn:alpine -f daily/%s/sdk/alpine.Dockerfile -c ./daily/%s/sdk -s ./daily/%s/daily.spec.toml" dotnetVersion |> convertCmd)

    let buildAllDailyImages () =
        let skip = FakeVar.getOrFail<string list> "SkipVersions"
        trackingVersions
        |> Seq.except skip
        |> Seq.iter buildDailyImages
    
    let commitChanges () =
        let skip = FakeVar.getOrFail<string list> "SkipVersions"
        let skipCommit =
            trackingVersions
            |> Seq.except skip
            |> Seq.isEmpty
        if not skipCommit then
            let now = DateTime.Now.ToString("O")
            runCmd "git" ["add"; "."]
            runCmd "git" ["commit"; "-m"; "DailyBuild: " + now]
            gitPush ()
        else ()

// ----------------------
// Targets
// ----------------------

Target.useTriggerCI ()

Target.create "CI:Build" (fun p -> handleCli p.Context.Arguments Docker.ciBuild)

Target.create "CI:Test" (fun _ -> Docker.testImage())

Target.create "CI:Publish" (fun _ -> Docker.publishImage())

Target.create "update:info" (fun p ->
    handleCli p.Context.Arguments BuildInfo.getDepsInfo
)

Target.create "CI" ignore

"CI:Build" ==> "CI:Test" ==> "CI:Publish" ==> "CI"

Target.create "daily:prepare" (fun _ ->
    FakeVar.set "SkipVersions" List.empty<string>
    DailyBuild.getAllDailyBuildInfo ()
    if checkTemplateUpdate() then
        FakeVar.set "SkipVersions" List.empty<string>
    FakeVar.getOrFail<string list> "SkipVersions"
    |> Seq.iter (Trace.tracefn "%s is up to date, will be skipped")
)

Target.create "daily:build" ( fun _ -> 
    DailyBuild.buildAllDailyImages ()
)

Target.create "daily:commit" ( fun _ ->
    DailyBuild.commitChanges ()
)

Target.create "daily" ignore

"daily:prepare" ==> "daily:build"
    ==> "daily:commit" ==> "daily"

Target.create "Empty" ignore

Target.runOrDefaultWithArguments "Empty"
