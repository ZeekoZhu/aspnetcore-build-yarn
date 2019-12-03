module BuildInfo

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

module DotNetRelease =
    type DotNetVersionInfo =
        {
            Version: string
            FileHash: string
        }
    type ReleaseChannelIndex = JsonProvider<"./sample-release.json">
    let getIndex (version: string) =
        async {
            let! releaseInfo = ReleaseChannelIndex.AsyncLoad (sprintf "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/%s/releases.json" version)
            let latestRelease =
                releaseInfo.Releases
                |> Seq.maxBy (fun x -> x.ReleaseDate)
            let findFileHash (arr: ReleaseChannelIndex.File2 array) =
                arr
                |> Seq.find (fun x ->
                    match x.Rid with
                    | Some rid when rid = "linux-musl-x64" -> true
                    | _ -> false
                    )
            let sdk: DotNetVersionInfo =
                { Version = latestRelease.Sdk.Version.String.Value; FileHash = (findFileHash latestRelease.Sdk.Files).Hash }
            let aspnetcoreRt: DotNetVersionInfo =
                { Version = latestRelease.AspnetcoreRuntime.Value.Version.String.Value;
                  FileHash = (findFileHash latestRelease.AspnetcoreRuntime.Value.Files).Hash
                }
            return sdk, aspnetcoreRt
        }

[<NoComparison>]
type BuildInfoOptions =
    { [<Option('d', "dotnet", Required = true)>] DotnetVersions: string seq
    }

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

let getImageVersion (tagListUrl: string) version =
    let versionPattern = @"""" + Regex.Escape(version) + @"\.\d+(?:-preview\d?)?"""
    let regex = Regex(versionPattern)
    task {
        let! resp = httpClient.GetStringAsync(tagListUrl)
        let result =
            seq {
                for _match in regex.Matches(resp) do
                    yield _match.Value.Trim([|'"'|]) |> SemVer.parse
            }
            |> Seq.max
        return result.AsString
    }
    |> Async.AwaitTask

let getSdkImage =
    getImageVersion "https://mcr.microsoft.com/v2/dotnet/core/sdk/tags/list"

let getAspNetImage =
    getImageVersion "https://mcr.microsoft.com/v2/dotnet/core/aspnet/tags/list"

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
    let dotnetInfo version isSdk =
        async {
            let! (sdk, aspnetcore) = DotNetRelease.getIndex version
            if isSdk then
                return "DotNet SDK", (sdk.Version, sdk.FileHash)
            else
                return "AspNetCore Runtime", (aspnetcore.Version, aspnetcore.FileHash)
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
    let aspnetImageTask version =
        async {
            let! resp = getAspNetImage version
            return "AspNetCore Image", (resp, "N/A")
        }
    let sdkImageVersion version =
        async {
            let! resp = getSdkImage version
            return "SDK Image", (resp, "N/A")
        }
    let tasks =
        seq {
            for v in options.DotnetVersions do
                yield aspnetImageTask v
                yield sdkImageVersion v
                yield dotnetInfo v true
                yield dotnetInfo v false
            yield nodejsTask
            yield yarnTask
        }
    Async.Parallel tasks
    |> Async.RunSynchronously
    |> Seq.iter (fun (name, (version, checksum)) ->
            Trace.logfn "%s:\nVersion: %s\nChecksum: %s\n" name version checksum
        )
