module CLI.Exec

open SimpleExec

let run p (args: string seq) = Command.Run(p, args)

let readAsync p (args: string seq) =
  async {
    let! out, _ = Command.ReadAsync(p, args) |> Async.AwaitTask
    return out
  }
