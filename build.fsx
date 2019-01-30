open System.Diagnostics
#load ".fake/build.fsx/intellisense.fsx"
#if !FAKE
  #r "Facades/netstandard"
#endif
open System
open Fake.Core
open Fake.DotNet
open Fake.IO
open Fake.IO.FileSystemOperators
open Fake.IO.Globbing.Operators
open Fake.Core.TargetOperators
open Fake.Tools
open CommandLine
open CommandLine.Text

// ----------------------
// Utils
// ----------------------

let runGitCmd command =
    let (success, stdout, stderr) = Git.CommandHelper.runGitCommand "./" command
    if success then stdout |> List.head
    else failwith stderr

let getLatestTag () =
    let revListResult =
        runGitCmd "rev-list --tags --max-count=1"
    let tagName =
        runGitCmd (sprintf "describe --tags %s" revListResult)
    tagName


// ----------------------
// Command Line Interface
// ----------------------

module Cli =
    type TriggerCIOptions =
        { [<Option('v', "version", Required = true)>] Version: string
          [<Option('l', "latest", Default = false)>] IsProd: bool
        }

    let ensureWorkspaceClean () =
        let isEmpty = Git.FileStatus.getAllFiles "./" |> Seq.isEmpty
        if not isEmpty then failwith "Workspace is not clean"
        isEmpty

    let validateVersion (options: TriggerCIOptions) =
        let newTag =
            if options.IsProd then options.Version
            else options.Version + "-" + Git.Information.getCurrentHash ()
            |> SemVer.parse
        let latestTag = getLatestTag () |> SemVer.parse
        Trace.tracefn "Latest version: %s" latestTag.AsString
        if newTag < latestTag then failwithf "Invalid version: %A < %A" newTag latestTag
        Trace.tracefn "New version: %s" newTag.AsString
        newTag

    let tagCurrent (tag) =
        Git.Branches.tag "./" tag

    let triggerCi (options: TriggerCIOptions) =
        Trace.logfn "%A" options
        ensureWorkspaceClean () |> ignore
        let version = validateVersion options
        tagCurrent version.AsString
        ()

    let triggerCiCli (args: seq<string>) =
        let parseResult =
            Parser.Default.ParseArguments<TriggerCIOptions> args
        match parseResult with
        | :? Parsed<TriggerCIOptions> as parsed -> triggerCi parsed.Value
        | :? NotParsed<TriggerCIOptions> as notParsed ->
            Trace.traceErrorfn "Invalid: %A, Errors: %A" args notParsed.Errors
        | _ -> failwith "Invalid parser result"

// ----------------------
// Targets
// ----------------------

let triggerCi (p: TargetParameter) =
    Cli.triggerCiCli p.Context.Arguments

Target.create "TriggerCI" triggerCi

Target.create "All" ignore

Target.runOrDefaultWithArguments "All"
