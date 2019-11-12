#load ".fake/build.fsx/intellisense.fsx"
#load "./utils.fsx"
#load "./build-info.fsx"
#load "./daily-build.fsx"
#load "./docker.fsx"

#if !FAKE
  #r "Facades/netstandard"
#endif
open Fake.Core
open Fake.Core.TargetOperators
open Fake.MyFakeTools

// ----------------------
// Targets
// ----------------------

Target.useTriggerCI ()

Target.create "CI:Build" (fun p -> Utils.handleCli p.Context.Arguments Docker.ciBuild)

Target.create "CI:Test" (fun _ -> Docker.testImage())

Target.create "CI:Publish" (fun _ -> Docker.publishImage())

Target.create "update:info" (fun p ->
    Utils.handleCli p.Context.Arguments BuildInfo.getDepsInfo
)

Target.create "CI" ignore

"CI:Build" ==> "CI:Test" ==> "CI:Publish" ==> "CI"

Target.create "daily:prepare" (fun _ ->
    FakeVar.set "SkipVersions" List.empty<string>
    DailyBuild.getAllDailyBuildInfo ()
    if Utils.checkTemplateUpdate() then
        FakeVar.set "SkipVersions" List.empty<string>
    FakeVar.getOrFail<string list> "SkipVersions"
    |> Seq.iter (Trace.tracefn "%s is up to date, will be skipped")
)

Target.create "daily:build" ( fun _ -> 
    DailyBuild.buildAllDailyImages ()
)

Target.create "daily:commit" ( fun _ ->
    DailyBuild.commitChanges ()
)

Target.create "daily" ignore

"daily:prepare" ==> "daily:build"
    ==> "daily:commit" ==> "daily"

Target.create "Empty" ignore

Target.runOrDefaultWithArguments "Empty"
