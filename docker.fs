module CLI.Docker

open System
open System.IO
open System.Text.RegularExpressions
open Microsoft.Extensions.Logging
open Microsoft.Extensions.DependencyInjection
open Nett
open Semver
open SimpleExec

type BuildOptions =
  { Tag: string
    Dockerfile: FileInfo
    ContextPath: DirectoryInfo
    Spec: string }

module Exec =
  let run p (args: string seq) = Command.Run(p, args)

  let readAsync p (args: string seq) =
    async {
      let! out, _ = Command.ReadAsync(p, args) |> Async.AwaitTask
      return out
    }


let build (options: BuildOptions) =
  Exec.run
    "docker"
    [ "build"
      "-t"
      options.Tag
      "-f"
      options.Dockerfile.FullName
      options.ContextPath.FullName ]



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
    Tag: string }

[<CLIMutable>]
type ImageSpec = { Images: ImageSpecItem [] }

let getBuildParams (specFile: string) (name: string) =
  let spec =
    Toml.ReadFile<ImageSpec>(specFile)

  spec.Images |> Seq.find (fun x -> x.Name = name)

let acceptList =
  [ "dotnet", "5.0.100-preview.7.20366.6", "5.0.100-preview.7.20366.15" ]

let inAcceptList versions = acceptList |> List.contains versions

let checkVersion (logger: ILogger) (item, itemValue, actualValue: string) =
  $"Q: Is %s{item}'s version %s{itemValue} ?"
  |> logger.info

  if itemValue.Trim() <> actualValue.Trim()
     && not
        <| inAcceptList (item, itemValue.Trim(), actualValue.Trim()) then
    logger.LogInformation $"A: No, %s{item}'s version is %s{actualValue}!"
    failwithf $"Test %s{item} failed"
  else
    logger.LogInformation "A: Yes!"

let dockerRunRm image args =
  Exec.readAsync "docker" ([ "run"; "--rm"; image ] @ args)

let dotnetVersion (imageSpec: ImageSpecItem) =
  async {
    if imageSpec.Sdk then
      return! dockerRunRm imageSpec.TestImage [ "dotnet"; "--version" ]
    else
      let reg =
        Regex("^  Microsoft.AspNetCore.App (?<runtime>.*) \\[.*\\]$", RegexOptions.Multiline)

      let! result = dockerRunRm imageSpec.TestImage [ "dotnet"; "--info" ]
      return (reg.Match(result).Groups.Item "runtime").Value
  }

let testImage (services: IServiceProvider) (imageSpec: ImageSpecItem) =
  let logger = services.GetService<ILogger>()

  if imageSpec.SkipTest then
    ()
  else
    [| dockerRunRm imageSpec.TestImage [ "node"; "--version" ]
       dockerRunRm imageSpec.TestImage [ "yarn"; "--version" ]
       dockerRunRm imageSpec.TestImage [ "volta"; "--version" ] |]
    |> Async.Parallel
    |> Async.RunSynchronously
    |> ignore

    let dotnetVersion =
      dotnetVersion imageSpec |> Async.RunSynchronously

    [ ("dotnet", dotnetVersion, imageSpec.Dotnet) ]
    |> List.iter (checkVersion logger)

let publishImage (services: IServiceProvider) (spec: ImageSpecItem) =
  let logger = services.GetService<ILogger>()
  let versionConfig = Versions.readVersions ()
  let latestVersion = versionConfig.Latest

  let version =
    SemVersion.Parse(spec.Dotnet, SemVersionStyles.Any)

  let major = string version.Major

  let minor =
    major + "." + string version.Minor

  let patch = version.ToString()

  seq {
    yield minor
    yield patch

    if spec.Latest && minor = latestVersion then
      yield "latest"
  }
  |> Seq.map (fun t ->
    let tag = spec.Tag + ":" + t

    if String.IsNullOrEmpty spec.Suffix then
      tag
    else
      tag + "-" + spec.Suffix)
  |> Seq.iter (fun t ->
    logger.info $"Pushing %s{t}"
    Exec.run "docker" [ "tag"; spec.TestImage; t ]
    Exec.run "docker" [ "push"; t ])

let ciBuild (services: IServiceProvider) (p: BuildOptions) =
  let buildParams =
    getBuildParams p.Spec p.Tag

  let buildOptions =
    { p with Tag = buildParams.TestImage }

  build buildOptions
  testImage services buildParams
  publishImage services buildParams
