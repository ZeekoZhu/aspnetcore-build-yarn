module Utils

#load ".fake/build.fsx/intellisense.fsx"
#if !FAKE
  #r "Facades/netstandard"
#endif
open System
open Fake.Core
open Fake.Tools
open CommandLine
open Nett

let showOutput =
    CreateProcess.redirectOutput
    >> (CreateProcess.withOutputEventsNotNull Trace.log Trace.traceError)
    >> CreateProcess.ensureExitCode

let runCmd file args =
    CreateProcess.fromRawCommand file args
    |> showOutput
    |> Proc.run
    |> ignore

let runCmdAndReturn file args =
    let result =
        CreateProcess.fromRawCommand file args
        |> showOutput
        |> Proc.run
    result.Result.Output

let dockerCmd (subCmd: string) (args: string list) = runCmd "docker" (subCmd::args)

let runGitCmd command =
    let (success, stdout, stderr) = Git.CommandHelper.runGitCommand "./" command
    if success then String.Join ("\n", stdout)
    else failwith stderr

let getLatestTag () =
    let revListResult =
        runGitCmd "rev-list --tags --max-count=1"
    let tagName =
        runGitCmd (sprintf "describe --tags %s" revListResult)
    tagName

let handleCli<'t> (args: seq<string>) (fn: 't -> unit) =
    let parseResult =
        Parser.Default.ParseArguments<'t> args
    match parseResult with
    | :? Parsed<'t> as parsed -> fn parsed.Value
    | :? NotParsed<'t> as notParsed ->
        failwithf "Invalid: %A, Errors: %A" args notParsed.Errors
    | _ -> failwith "Invalid parser result"

let gitPush () =
    let gitUsr = Environment.environVar "GITHUB_USER"
    let gitToken = Environment.environVar "GITHUB_TOKEN"
    let branch = Environment.environVar "GITHUB_REF"
    runCmd "git" ["push"; sprintf "https://%s:%s@github.com/ZeekoZhu/aspnetcore-build-yarn" gitUsr gitToken; sprintf "HEAD:%s" branch ]

let checkTemplateUpdate () =
    let changed =
        runGitCmd "diff --name-only HEAD~1"
    Trace.trace changed
    changed.Contains "daily-template/"
