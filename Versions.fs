module CLI.Versions


open Nett
open Fake.IO
open Fake.IO.FileSystemOperators

[<CLIMutable>]
type VersionsConfig =
    { TrackingVersions: string []
      Latest: string
    }

let readVersions () =
    File.readAsString (Variables.ScriptRoot </> "./versions.toml")
    |> Toml.ReadString<VersionsConfig> 
