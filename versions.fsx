module Versions

#load ".fake/build.fsx/intellisense.fsx"
#load "./variables.fsx"

open Nett
open Fake.IO.FileSystemOperators
open Fake.IO

[<CLIMutable>]
type VersionsConfig =
    { TrackingVersions: string []
      Latest: string
    }

let readVersions () =
    File.readAsString (Variables.ScriptRoot </> "./versions.toml")
    |> Toml.ReadString<VersionsConfig> 
