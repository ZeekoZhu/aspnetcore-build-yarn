module CLI.BuildInfo

open System
open System.Text.RegularExpressions
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

  type ReleaseChannelIndex =
    JsonProvider<Sample="./sample-release.json", InferTypesFromValues=false>

  let parseImageVersion str =
    let regex =
      Regex("""^\d+\.\d+\.\d+(-\w+(\.\d+)?)?""")

    (regex.Match(str)).Value

  let getIndex (version: string) =
    async {
      let! releaseInfo =
        ReleaseChannelIndex.AsyncLoad(
          sprintf
            "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/%s/releases.json"
            version
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
type BuildInfoOptions = { DotnetVersions: string seq }

let getDepsInfo (services: IServiceProvider) (options: BuildInfoOptions) =
  let dotnetInfo version =
    async {
      let! dotnetRelease = DotNetRelease.getIndex version

      return
        seq {
          $"DotNet SDK: %A{dotnetRelease.Sdk}"
          $"AspNetCore Runtime: %A{dotnetRelease.AspNetCore}"

          $"SDK Image: %A{DotNetRelease.parseImageVersion dotnetRelease.Sdk.Version}"

          $"AspNetCore Runtime Image: %A{DotNetRelease.parseImageVersion dotnetRelease.AspNetCore.Version}"

          $"Runtime: %A{dotnetRelease.Runtime}"
        }
    }

  for v in options.DotnetVersions do
    dotnetInfo v
    |> Async.RunSynchronously
    |> Seq.iter (printfn "%s" )
