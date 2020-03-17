module BuildInfo
open AngleSharp

#load ".fake/build.fsx/intellisense.fsx"
#if !FAKE
  #r "Facades/netstandard"
#endif
open System.Text.RegularExpressions
open Fake.Core
open CommandLine
open FSharp.Control.Tasks.V2
open FSharp.Data
open System.Net.Http

let httpClient = new HttpClient()

let browserCtx = BrowsingContext.New (Configuration.Default)

module DotNetRelease =
    type DotNetVersionInfo =
        {
            Version: string
            FileHash: string
        }
    type DotNetRelease =
        { Sdk: DotNetVersionInfo
          Runtime: DotNetVersionInfo
          AspNetCore: DotNetVersionInfo
        }

    type ReleaseChannelIndex = JsonProvider<Sample = "./sample-release.json", InferTypesFromValues = false>
    let parseImageVersion str =
        let regex = Regex("""\d+\.\d+\.\d+(-\w+)?""")
        (regex.Match(str)).Value
    let getIndex (version: string) =
        async {
            let! releaseInfo = ReleaseChannelIndex.AsyncLoad (sprintf "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/%s/releases.json" version)
            let latestRelease =
                releaseInfo.Releases
                |> Seq.maxBy (fun x -> x.ReleaseDate)
            let findFileHash (arr: ReleaseChannelIndex.File array) =
                arr
                |> Seq.find (fun x -> x.Rid = "linux-musl-x64")
            let sdk: DotNetVersionInfo =
                { Version = latestRelease.Sdk.Version
                  FileHash = (findFileHash latestRelease.Sdk.Files).Hash
                }
            let aspnetcoreRt: DotNetVersionInfo =
                { Version = latestRelease.AspnetcoreRuntime.Version;
                  FileHash = (findFileHash latestRelease.AspnetcoreRuntime.Files).Hash
                }
            let runtime: DotNetVersionInfo =
                { Version = latestRelease.Runtime.Version
                  FileHash = (findFileHash latestRelease.Runtime.Files).Hash
                }
            return { Sdk = sdk; Runtime = runtime; AspNetCore = aspnetcoreRt }
        }

[<NoComparison>]
type BuildInfoOptions =
    { [<Option('d', "dotnet", Required = true)>] DotnetVersions: string seq
    }

let parseYanrInfo downloadPage =
    task {
        let! doc = browserCtx.OpenAsync (fun req -> req.Content(downloadPage) |> ignore)
        return doc.QuerySelector(".navbar-text").TextContent.Trim().TrimStart('v')
    }
    |> Async.AwaitTask
    |> Async.RunSynchronously

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

let getNodeJsInfoAsync () =
    task {
        let! resp = httpClient.GetStringAsync("https://nodejs.org/en/download/")
        let result = (parseNodejsInfo resp)
        return result
    } |> Async.AwaitTask

let getYarnInfoAsync () =
    task {
        let! resp = httpClient.GetStringAsync("https://yarnpkg.com/en")
        return parseYanrInfo resp
    } |> Async.AwaitTask

let getDepsInfo (options: BuildInfoOptions) =
    let dotnetInfo version =
        async {
            let! dotnetRelease = DotNetRelease.getIndex version
            return seq {
                sprintf "DotNet SDK: %A" dotnetRelease.Sdk 
                sprintf "AspNetCore Runtime: %A" dotnetRelease.AspNetCore
                sprintf "SDK Image: %A" (DotNetRelease.parseImageVersion dotnetRelease.Sdk.Version)
                sprintf "AspNetCore Runtime Image: %A" (DotNetRelease.parseImageVersion dotnetRelease.AspNetCore.Version)
                sprintf "Runtime: %A" dotnetRelease.Runtime
            }
        }
    let nodejsTask =
        async {
            let! resp = getNodeJsInfoAsync ()
            let result = "Node.js", resp
            return result
        }
    let yarnTask =
        async {
            let! resp = getYarnInfoAsync ()
            let result = "Yarn", (resp, "N/A")
            return result
        }
    let printVersionInfo = (fun (name, (version, checksum)) ->
            Trace.logfn "%s:\nVersion: %s\nChecksum: %s\n" name version checksum
        )
    let tasks =
        seq {
            yield nodejsTask
            yield yarnTask
        }
    Async.Parallel tasks
    |> Async.RunSynchronously
    |> Seq.iter printVersionInfo
    for v in options.DotnetVersions do
        dotnetInfo v
        |> Async.RunSynchronously
        |> Seq.iter (Trace.logfn "%s")
