module CLI.Daily

open System
open System.CommandLine

let command = Command("daily")

let handler (services: IServiceProvider) =
  let skipVersions = DailyBuild.getAllDailyBuildInfo []
  let skipVersions =
    if Utils.checkTemplateUpdate() then
      List.empty<string>
    else
      skipVersions
  skipVersions
  |> Seq.iter (printfn "%s is up to date, will be skipped")
  DailyBuild.buildAllDailyImages services skipVersions
  DailyBuild.commitChanges skipVersions

let services = ServiceProviderBinder.registerServices ignore

command.SetHandler (handler, services)
