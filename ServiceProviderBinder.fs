module CLI.ServiceProviderBinder

open System
open System.CommandLine.Binding
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Logging

type internal ServiceProviderBinder(builder: IServiceCollection -> unit) =
  inherit BinderBase<IServiceProvider>()

  override self.GetBoundValue _ =
    let services = ServiceCollection()
    builder services

    services.AddLogging (fun conf ->
      conf.AddFilter("ci", LogLevel.Debug).AddConsole()
      |> ignore)
    |> ignore

    let result = services.BuildServiceProvider()
    result

let registerServices (builder: IServiceCollection -> unit) =
  ServiceProviderBinder(builder) :> BinderBase<IServiceProvider>
