defmodule Notifier.Bot do
  require Logger
  use GenServer

  @bot Application.get_env(:notifier, :bot, "qmonibot")

  def start_link() do
    Logger.debug "Starting #{__MODULE__}"
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def run(offset \\ 0) do
    {:ok, updates} = Nadia.get_updates(offset: offset)

    next_offset =
      case List.last updates do
        nil -> offset
        upd -> upd.update_id + 1
      end

    Enum.map(updates, &process(&1))

    run(next_offset)
  end

  def process(%{message: message=%{chat: chat}}) do
    react(:message, chat.id, message)
  end

  def process(_other) do
    # Logger.debug "upd: #{inspect _other}"
    :ok
  end

  def react(:message, _chat_id, %{chat: chat, text: "/start" <> rest})
  when rest in ["", "@#{@bot}"] do
    Tgchats.add_chat(chat)

    for {key, {date, data}} <- Storage.get_latest do
      Notifier.notify(chat.id, key, date, data)
    end

  end

  def react(:message, _chat_id, %{chat: chat, text: "/stop" <> rest})
  when rest in ["", "@#{@bot}"] do
    Tgchats.remove_chat(chat)
  end

  def react(_, _, _), do: :ok

  ########### callbacks
  def init(_) do
    pid = spawn_link(__MODULE__, :run, [])
    Logger.debug "#{__MODULE__} poller pid: #{inspect pid}"
    {:ok, pid}
  end
end
