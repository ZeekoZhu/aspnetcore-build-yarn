[<AutoOpen>]
module CLI.Logging

open Microsoft.Extensions.Logging

type ILogger with
  member self.info s = self.LogInformation s
