defmodule Checker.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Checker.Worker.start_link(arg1, arg2, arg3)
      # worker(Checker.Worker, [arg1, arg2, arg3]),
      # worker(Checker.Geshinfo, []),
      worker(Checker.Gesh, []),
      worker(Checker.Sheregeshsu, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Checker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
