open System.CommandLine
open CLI

let rootCmd = RootCommand()

rootCmd.AddCommand CI.command
rootCmd.AddCommand UpdateInfo.command
// todo: update info command
// todo: daily command

let [<EntryPoint>] main args =
  rootCmd.Invoke args
