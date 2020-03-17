module DailyBuild

#load ".fake/build.fsx/intellisense.fsx"
#load "./build-info.fsx"
#load "./utils.fsx"
#load "./versions.fsx"
#if !FAKE
  #r "Facades/netstandard"
#endif
open System
open System.IO
open Fake.Core
open Nett
open Fake.MyFakeTools
open Utils

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
      RuntimeVersion: string
      RuntimeSHA: string
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
        let! release = DotNetRelease.getIndex dotnetVersion
        let aspnet = release.AspNetCore
        let sdk = release.Sdk
        let runtime = release.Runtime
        let! yarnVersion = getYarnInfoAsync ()
        let depsVersion = aspnet.Version
        let aspnetImage = DotNetRelease.parseImageVersion aspnet.Version
        let sdkImage = DotNetRelease.parseImageVersion sdk.Version
        return
            { NodeVersion = nodeVersion
              YarnVersion = yarnVersion
              NodeSHA = nodeSha
              DepsVersion = depsVersion
              AspNetCoreVersion = aspnet.Version
              AspNetCoreSHA = aspnet.FileHash
              AspNetImage = aspnetImage
              SdkSHA = sdk.FileHash
              SdkVersion = sdk.Version
              SdkImage = sdkImage
              RuntimeVersion = runtime.Version
              RuntimeSHA = runtime.FileHash
              FetchTime = DateTime.Now.ToString("O")
            }
    }

let trackingVersions =
    (Versions.readVersions ()).TrackingVersions

let getAllDailyBuildInfo () =
    for version in trackingVersions do
        let infoFile = "daily" </> version </> "daily-build-info.toml"
        
        let info =
            getDailyBuildInfo version |> Async.RunSynchronously
        let previousInfo =
            { (File.readAsString infoFile
                |> Toml.ReadString<DailyBuildInfo>)
                with
                    FetchTime = info.FetchTime
            }
        Directory.ensure ("daily" </> version)
        if info = previousInfo then
            let skip = FakeVar.getOrFail<string list> "SkipVersions"
            FakeVar.set "SkipVersions" (version::skip)
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
