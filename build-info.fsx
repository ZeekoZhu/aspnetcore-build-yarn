module BuildInfo

#load ".fake/build.fsx/intellisense.fsx"
#if !FAKE
  #r "Facades/netstandard"
#endif
open System.Text.RegularExpressions
open Fake.Core
open CommandLine
open FSharp.Control.Tasks.V2
open System.Net.Http

let httpClient = new HttpClient()

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
        let! resp = httpClient.GetStringAsync(sprintf "https://raw.githubusercontent.com/dotnet/dotnet-docker/master/%s/sdk/alpine3.10/amd64/Dockerfile" version)
        return (parseDotnetSdkInfo resp)
    } |> Async.AwaitTask

let getRuntimeInfoAsync version =
    task {
        let! resp = httpClient.GetStringAsync(sprintf "https://raw.githubusercontent.com/dotnet/dotnet-docker/master/%s/aspnet/alpine3.10/amd64/Dockerfile" version)
        let result = (parseAspNetInfo resp)
        return result
    } |> Async.AwaitTask

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
    let sdkInfoTask version =
        async {
            let! resp = getSdkInfoAsync version
            let result = "Dotnet SDK", resp
            return result
        }
    let runtimeTask version =
        async {
            let! resp = getRuntimeInfoAsync version
            let result = "AspNetCore Runtime", resp
            return result
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
                yield sdkInfoTask v
                yield runtimeTask v
                yield aspnetImageTask v
                yield sdkImageVersion v
            yield nodejsTask
            yield yarnTask
        }
    Async.Parallel tasks
    |> Async.RunSynchronously
    |> Seq.iter (fun (name, (version, checksum)) ->
            Trace.logfn "%s:\nVersion: %s\nChecksum: %s\n" name version checksum
        )
