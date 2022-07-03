open System.CommandLine
open CLI

let rootCmd = RootCommand()

rootCmd.AddCommand CI.command
rootCmd.AddCommand UpdateInfo.command
rootCmd.AddCommand Daily.command

let [<EntryPoint>] main args =
  rootCmd.Invoke args
