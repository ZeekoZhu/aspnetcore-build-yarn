module CLI.UpdateInfo

open System
open System.CommandLine

let command = Command("update-info")

let private versionsOpt =
  Option<string seq>([| "-d"; "--dotnet" |], IsRequired = true)

command.Add(versionsOpt)

let handler (versions: string seq) (services: IServiceProvider) =
  BuildInfo.getDepsInfo services { DotnetVersions = versions }

let services =
  ServiceProviderBinder.registerServices ignore

command.SetHandler(handler, versionsOpt, services)
