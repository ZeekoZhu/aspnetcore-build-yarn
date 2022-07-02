module DailyBuild

open System
open System.IO
open CLI.CI
open Nett

open CLI.BuildInfo
open CLI
open Docker

open Fake.IO
open Fake.IO.FileSystemOperators
open Fake.IO.Globbing.Operators

[<CLIMutable>]
type DailyBuildInfo =
  { AspNetCoreVersion: string
    AspNetImage: string
    SdkVersion: string
    SdkImage: string
    RuntimeVersion: string
    FetchTime: string }

module Templating =
  let getAllTemplates () = !! "daily-template/**/*"

  let templatingFile (info: DailyBuildInfo) template =
    info.GetType().GetProperties()
    |> Seq.map (fun prop -> prop.Name, (prop.GetValue(info) :?> string))
    |> Seq.fold
         (fun (templ: string) (propName, value) ->
           templ.Replace((sprintf "{{%s}}" propName), value))
         template

  let renderAllTemplates dotnetVersion info =
    for templ in getAllTemplates () do
      let content = File.ReadAllText templ
      let rendered = templatingFile info content

      let outputPath =
        templ.Replace("daily-template", "daily" </> dotnetVersion)

      Directory.ensure (Directory.GetParent(outputPath).FullName)
      File.WriteAllText(outputPath, rendered)

let dotnetDockerRepo (dotnetVersion: string) imgType (imgVersion: string) =
  if imgVersion.Contains "preview" then
    sprintf "mcr.microsoft.com/dotnet/nightly/%s:%s" imgType imgVersion
  else
    sprintf "mcr.microsoft.com/dotnet/%s:%s" imgType imgVersion



let getDailyBuildInfo (dotnetVersion) =
  async {
    let! release = DotNetRelease.getIndex dotnetVersion
    let aspnet = release.AspNetCore
    let sdk = release.Sdk
    let runtime = release.Runtime

    let aspnetImage =
      DotNetRelease.parseImageVersion aspnet.Version

    let aspnetImage =
      dotnetDockerRepo dotnetVersion "aspnet" aspnetImage

    let sdkImage =
      DotNetRelease.parseImageVersion sdk.Version

    let sdkImage =
      dotnetDockerRepo dotnetVersion "sdk" sdkImage

    return
      { AspNetCoreVersion = aspnet.Version
        AspNetImage = aspnetImage
        SdkVersion = sdk.Version
        SdkImage = sdkImage
        RuntimeVersion = runtime.Version
        FetchTime = DateTime.Now.ToString("O") }
  }

let trackingVersions =
  (Versions.readVersions ()).TrackingVersions

let getPreviousInfo infoFile =
  if File.exists infoFile then
    File.readAsString infoFile
    |> Toml.ReadString<DailyBuildInfo>
    |> Some
  else
    None

let isBuildInfoEqual a b =
  printfn $"is equal {a} {b}"
  a = { b with FetchTime = a.FetchTime }

let getAllDailyBuildInfo (skipVersions: string list) =
  seq {
    yield! skipVersions

    for version in trackingVersions do
      Directory.ensure ("daily" </> version)

      let infoFile =
        "daily" </> version </> "daily-build-info.toml"

      let info =
        getDailyBuildInfo version
        |> Async.RunSynchronously

      let shouldSkip =
        getPreviousInfo infoFile
        |> Option.map (isBuildInfoEqual info)
        |> Option.defaultValue false

      File.writeString false infoFile (Toml.WriteString info)
      Templating.renderAllTemplates version info

      if shouldSkip then yield version
  }
  |> List.ofSeq

let buildDailyImages (services: IServiceProvider) dotnetVersion =

  [ { Tag = "zeekozhu/aspnetcore-build-yarn"
      Dockerfile =
        $"daily/{dotnetVersion}/sdk/Dockerfile"
        |> FileInfo
      ContextPath = $"./daily/{dotnetVersion}/sdk" |> DirectoryInfo
      Spec = $"./daily/{dotnetVersion}/daily.spec.toml" }
    { Tag = "zeekozhu/aspnetcore-build-yarn:chromium"
      Dockerfile =
        $"daily/{dotnetVersion}/sdk/chromium.Dockerfile"
        |> FileInfo
      ContextPath = $"./daily/{dotnetVersion}/sdk" |> DirectoryInfo
      Spec = $"./daily/{dotnetVersion}/daily.spec.toml" }
    { Tag = "zeekozhu/aspnetcore-node"
      Dockerfile =
        $"daily/{dotnetVersion}/runtime/Dockerfile"
        |> FileInfo
      ContextPath =
        $"./daily/{dotnetVersion}/runtime"
        |> DirectoryInfo
      Spec = $"./daily/{dotnetVersion}/daily.spec.toml" } ]
  |> List.iter (fun it -> Build.handler it services)

let buildAllDailyImages
  (services: IServiceProvider)
  (skipVersions: string seq)
  =

  trackingVersions
  |> Seq.except skipVersions
  |> Seq.iter (buildDailyImages services)

let commitChanges (skipVersions: string seq) =
  let skipCommit =
    trackingVersions
    |> Seq.except skipVersions
    |> Seq.isEmpty

  if not skipCommit then
    let now = DateTime.Now.ToString("O")
    Exec.run "git" [ "config"; "user.name"; "ZeekoZhu" ]

    Exec.run
      "git"
      [ "config"
        "user.email"
        "vaezt@outlook.com" ]

    Exec.run "git" [ "add"; "." ]
    Exec.run "git" [ "commit"; "-m"; "DailyBuild: " + now ]
    Utils.gitPush ()
  else
    ()
