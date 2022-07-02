module CLI.CI

open System
open System.CommandLine
open System.CommandLine.Binding
open System.IO
open Docker
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Logging

let command = Command("ci")

module Build =
  let tagOpt =
    Option<string>([| "-t"; "--tag" |], "image tag", IsRequired = true)

  let dockerfileOpt =
    Option<FileInfo>(
      [| "-f"; "--dockerfile" |],
      "dockerfile to build",
      IsRequired = true
    )

  let ctxPathOpt =
    Option<DirectoryInfo>(
      [| "-c"; "--context-dir" |],
      "docker build context dir",
      IsRequired = true
    )

  let specOpt =
    Option<string>(
      [| "-s"; "--spec" |],
      "build info specification file",
      IsRequired = true
    )

  type BuildOptionBinder() =
    inherit BinderBase<BuildOptions>()

    override self.GetBoundValue(ctx) =
      let valueOf x = ctx.ParseResult.GetValueForOption x

      { Tag = valueOf tagOpt
        Dockerfile = valueOf dockerfileOpt
        ContextPath = valueOf ctxPathOpt
        Spec = valueOf specOpt }

  type ServiceProviderBinder() =
    inherit BinderBase<IServiceProvider>()

    override self.GetBoundValue _ =
      let services = ServiceCollection()

      services.AddLogging (fun conf ->
        conf.AddFilter("ci", LogLevel.Debug).AddConsole()
        |> ignore)
      |> ignore

      services.BuildServiceProvider()

  let command = Command("build")

  let services =
    ServiceProviderBinder.registerServices ignore

  command.Add tagOpt
  command.Add dockerfileOpt
  command.Add ctxPathOpt
  command.Add specOpt

  let handler (opt: BuildOptions) (services: IServiceProvider) =
    ciBuild services opt

  command.SetHandler<BuildOptions, IServiceProvider>(
    handler,
    BuildOptionBinder(),
    services
  )

command.AddCommand Build.command
