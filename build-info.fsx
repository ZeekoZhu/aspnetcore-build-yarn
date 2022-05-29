module BuildInfo

#load ".fake/build.fsx/intellisense.fsx"

open System.Text.RegularExpressions
open Fake.Core
open CommandLine
open FSharp.Data
open System.Net.Http
open Fake.MyFakeTools
open Microsoft.FSharp.Control
open FsToolkit.ErrorHandling

let httpClient = new HttpClient()

module DotNetRelease =
  type DotNetVersionInfo = { Version: string; FileHash: string }

  type DotNetRelease =
    { Sdk: DotNetVersionInfo
      Runtime: DotNetVersionInfo
      AspNetCore: DotNetVersionInfo }

  type ReleaseChannelIndex = JsonProvider<Sample="./sample-release.json", InferTypesFromValues=false>

  let parseImageVersion str =
    let regex =
      Regex("""^\d+\.\d+\.\d+(-\w+(\.\d+)?)?""")

    (regex.Match(str)).Value

  let getIndex (version: string) =
    async {
      let! releaseInfo =
        ReleaseChannelIndex.AsyncLoad(
          sprintf "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/%s/releases.json" version
        )

      let latestRelease =
        releaseInfo.Releases
        |> Seq.maxBy (fun x -> x.ReleaseDate)

      let findFileHash (arr: ReleaseChannelIndex.File array) =
        arr
        |> Seq.find (fun x -> x.Rid = "linux-musl-x64")

      let sdk: DotNetVersionInfo =
        { Version = latestRelease.Sdk.Version
          FileHash = (findFileHash latestRelease.Sdk.Files).Hash }

      let aspnetcoreRt: DotNetVersionInfo =
        { Version = latestRelease.AspnetcoreRuntime.Version
          FileHash =
            (findFileHash latestRelease.AspnetcoreRuntime.Files)
              .Hash }

      let runtime: DotNetVersionInfo =
        { Version = latestRelease.Runtime.Version
          FileHash = (findFileHash latestRelease.Runtime.Files).Hash }

      return
        { Sdk = sdk
          Runtime = runtime
          AspNetCore = aspnetcoreRt }
    }

[<NoComparison>]
type BuildInfoOptions =
  { [<Option('d', "dotnet", Required = true)>]
    DotnetVersions: string seq }

let getVoltaToolVersion (tool: string) =
  async {
    Utils.runCmd "volta" [ "install"; $"{tool}@latest" ]

    let! result =
      CreateProcess.fromRawCommandLine "volta" "list -d --format plain"
      |> Utils.showOutput
      |> Proc.startAndAwait

    if result.ExitCode = 0 then
      let pattern =
        Regex($"""{tool}@([0-9.]+)""")

      let nodeVersion =
        pattern.Matches(result.Result.Output).[0].Groups.[1]
          .Value

      return nodeVersion |> Result.Ok
    else
      return result.Result.Output |> Result.Error
  }

let getNodeJsInfoAsyncV2 () = getVoltaToolVersion "node"
let getYarnInfoAsyncV2 () = getVoltaToolVersion "yarn"

let getDepsInfo (options: BuildInfoOptions) =
  let dotnetInfo version =
    async {
      let! dotnetRelease = DotNetRelease.getIndex version

      return
        seq {
          sprintf "DotNet SDK: %A" dotnetRelease.Sdk
          sprintf "AspNetCore Runtime: %A" dotnetRelease.AspNetCore
          sprintf "SDK Image: %A" (DotNetRelease.parseImageVersion dotnetRelease.Sdk.Version)
          sprintf "AspNetCore Runtime Image: %A" (DotNetRelease.parseImageVersion dotnetRelease.AspNetCore.Version)
          sprintf "Runtime: %A" dotnetRelease.Runtime
        }
    }

  let withName name = AsyncResult.map (fun r -> name, r)

  let nodejsTask =
    getNodeJsInfoAsyncV2 () |> withName "node"

  let yarnTask =
    getYarnInfoAsyncV2 () |> withName "yarn"

  let printVersionInfo =
    function
    | Result.Ok (name, version) -> Trace.logfn $"{name}@{version}"
    | Result.Error error -> Trace.traceErrorfn $"%s{error}"

  Async.Parallel(
    seq {
      nodejsTask
      yarnTask
    }
  )
  |> Async.RunSynchronously
  |> Seq.iter printVersionInfo

  for v in options.DotnetVersions do
    dotnetInfo v
    |> Async.RunSynchronously
    |> Seq.iter (Trace.logfn "%s")
