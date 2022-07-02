module CLI.UpdateInfo

open System
open System.CommandLine
open Microsoft.Extensions.Logging
open Microsoft.Extensions.DependencyInjection

let command = Command("update-info")

let private versionsOpt =
  Option<string seq>([| "-d"; "--dotnet" |], IsRequired = true)

command.Add(versionsOpt)

let handler (versions: string seq) (services: IServiceProvider) =
  BuildInfo.getDepsInfo services { DotnetVersions = versions }

let services =
  ServiceProviderBinder.registerServices ignore

command.SetHandler(handler, versionsOpt, services)
