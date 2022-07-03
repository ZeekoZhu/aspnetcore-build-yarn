module Utils

open System
open SimpleExec


let dockerCmd (subCmd: string) (args: string list) =
  Command.Run("docker", subCmd :: args)

let runGitCmd (command: string) =
  task {
    let! out, _ = Command.ReadAsync("git", command, workingDirectory = "./")
    return out
  }
  |> Async.AwaitTask
  |> Async.RunSynchronously


let getLatestTag () =
  let revListResult =
    runGitCmd "rev-list --tags --max-count=1"

  let tagName =
    runGitCmd $"describe --tags %s{revListResult}"

  tagName

let gitPush () =
  let gitUsr =
    Environment.GetEnvironmentVariable "GITHUB_USER"

  let gitToken =
    Environment.GetEnvironmentVariable "GITHUB_TOKEN"

  let branch =
    Environment.GetEnvironmentVariable "GITHUB_REF"

  Command.Run(
    "git",
    [ "push"
      $"https://%s{gitUsr}:%s{gitToken}@github.com/ZeekoZhu/aspnetcore-build-yarn"
      $"HEAD:%s{branch}" ]
  )

let checkTemplateUpdate () =
  let changed = runGitCmd "ls-files -m"
  printfn $"{changed}"
  changed.Contains "daily-template/"

let failIfError =
  function
  | Result.Ok value -> value
  | Result.Error err -> failwith $"%A{err}"

