module Docker

#load ".fake/build.fsx/intellisense.fsx"
#load "./variables.fsx"
#load "./versions.fsx"
#if !FAKE
  #r "Facades/netstandard"
#endif
open System.IO
open System.Text.RegularExpressions
open Fake.Core
open CommandLine
open Nett
open Fake.MyFakeTools
open Variables

type BuildOptions =
    { [<Option('t', Required = true)>] Tag: string
      [<Option('f', Required = true)>] Dockerfile: string
      [<Option('c', Required = true)>] ContextPath: string
      [<Option('s', "spec", Required = true)>] Spec: string
    }

let build (options: BuildOptions) =
    Utils.dockerCmd "build"
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
            Utils.runCmdAndReturn "docker" (["run"; "--rm"; imageSpec.TestImage; ] @ args)

        let acceptList = [ 
                "dotnet", "5.0.100-preview.7.20366.6", "5.0.100-preview.7.20366.15"
            ]
        let inAcceptList versions =
            acceptList |> List.contains versions
        let checkVersion item itemValue (actualValue: string) =
            Trace.tracefn "Q: Is %s's version %s ?" item itemValue
            if itemValue.Trim() <> actualValue.Trim() && not <| inAcceptList (item, itemValue.Trim(), actualValue.Trim())
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

let publishImage () =
    let spec = FakeVar.getOrFail<ImageSpecItem> BuildParams
    let versionConfig = Versions.readVersions ()
    let latestVersion = versionConfig.Latest
    let version = SemVer.parse spec.Dotnet
    let major = string version.Major
    let minor = major + "." + string version.Minor
    let patch = version.Original.Value
    seq {
        yield minor
        yield patch
        if spec.Latest && minor = latestVersion then yield "latest"
    }
    |> Seq.map (fun t ->
         let tag = spec.Tag + ":" + t
         if String.isNullOrEmpty spec.Suffix then tag
         else tag + "-" + spec.Suffix
       )
    |> Seq.iter (fun t ->
        Trace.tracefn "Pushing %s" t
        Utils.dockerCmd "tag" [ spec.TestImage; t ]
        Utils.dockerCmd "push" [ t ]
       )

let ciBuild (p: BuildOptions) =
    let buildParams = getBuildParams p.Spec p.Tag
    let buildOptions = { p with Tag = buildParams.TestImage }
    build buildOptions
    FakeVar.set BuildParams buildParams
