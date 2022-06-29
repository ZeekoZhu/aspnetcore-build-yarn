open System.CommandLine
open CLI

let rootCmd = RootCommand()

rootCmd.AddCommand CI.command

let [<EntryPoint>] main args =
  rootCmd.Invoke args
