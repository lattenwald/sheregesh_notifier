defmodule Storage.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    table = Application.get_env(:storage, :table, :storage)

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Storage.Worker.start_link(arg1, arg2, arg3)
      # worker(Storage.Worker, [arg1, arg2, arg3]),
      worker(Storage, [table]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Storage.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
