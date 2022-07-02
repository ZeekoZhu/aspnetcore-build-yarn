module CLI.Versions


open Nett
open Fake.IO

[<CLIMutable>]
type VersionsConfig =
    { TrackingVersions: string []
      Latest: string
    }

let readVersions () =
    File.readAsString "./versions.toml"
    |> Toml.ReadString<VersionsConfig> 
