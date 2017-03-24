defmodule Checker do
  @period Application.get_env(:checker, :period, 15)*60*1000

  require Logger
  use GenServer

  def start_link(key, fun) do
    Logger.debug "Starting #{__MODULE__} for #{inspect key}"
    GenServer.start_link(__MODULE__, {key, fun})
  end

  ######### callbacks
  def init({key, fun}) do
    send(self(), :check)
    :timer.send_interval(@period, self(), :check)
    {:ok, {key, fun}}
  end

  def handle_info(:check, state={key, fun}) do
    fun.()
    |> case do
         nil ->
           Logger.warn "#{__MODULE__} #{inspect key} failed fetching data"
         {date, data} ->
           Storage.store({{key, date}, data})
           |> case do
                :inserted -> Notifier.notify(key, date, data)
                # :exists   -> Notifier.notify(key, date, data)
                :exists   -> :ok
              end
       end
    {:noreply, state}
  end

  def handle_info(info, state) do
    Logger.warn "unexpected info: #{inspect info}, state: #{inspect state}"
  end
end
