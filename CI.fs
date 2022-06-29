module CLI.CI

open System.CommandLine
open System.CommandLine.Binding
open System.IO
open Docker
open Microsoft.Extensions.Logging

let command = Command("ci")

module Build =
  let tagOpt =
    Option<string>([| "t" |], IsRequired = true)

  let dockerfileOpt =
    Option<FileInfo>([| "f" |], IsRequired = true)

  let ctxPathOpt =
    Option<DirectoryInfo>([| "c" |], IsRequired = true)

  let specOpt =
    Option<string>([| "s"; "spec" |], IsRequired = true)

  type BuildOptionBinder() =
    inherit BinderBase<BuildOptions>()

    override self.GetBoundValue(ctx) =
      let valueOf x = ctx.ParseResult.GetValueForOption x

      { Tag = valueOf tagOpt
        Dockerfile = valueOf dockerfileOpt
        ContextPath = valueOf ctxPathOpt
        Spec = valueOf specOpt }

  type LoggerBinder() =
    inherit BinderBase<ILogger>()

    override self.GetBoundValue _ =
      LoggerFactory
        .Create(fun builder -> builder.AddConsole() |> ignore)
        .CreateLogger()

  let command = Command("build")

  command.Add tagOpt
  command.Add dockerfileOpt
  command.Add ctxPathOpt
  command.Add specOpt

  let handler (opt: BuildOptions) (log: ILogger) = log.LogInformation($"{opt}")

  command.SetHandler<BuildOptions, ILogger>(handler, BuildOptionBinder(), LoggerBinder())


command.AddCommand Build.command
