module BuildInfo

#load ".fake/build.fsx/intellisense.fsx"

open System.Text.RegularExpressions
open Fake.Core
open CommandLine
open FSharp.Data
open System.Net.Http
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

  for v in options.DotnetVersions do
    dotnetInfo v
    |> Async.RunSynchronously
    |> Seq.iter (Trace.logfn "%s")
