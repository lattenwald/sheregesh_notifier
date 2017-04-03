defmodule Tgchats do
  use GenServer
  require Logger

  @ets_table __MODULE__

  def start_link(table_name) do
    GenServer.start_link(__MODULE__, table_name, name: __MODULE__)
  end

  def add_chat(chat) do
    GenServer.call(__MODULE__, {:add_chat, chat})
  end

  def list_chats() do
    :ets.foldl(fn {_chat_id, chat}, acc -> [chat|acc] end, [], @ets_table)
  end

  def get_chat(chat_id) do
    case :ets.lookup(@ets_table, chat_id) do
      [{^chat_id, c}] -> c
      _ -> nil
    end
  end

  def remove_chat(id) when is_number(id) do
    GenServer.call(__MODULE__, {:remove_chat, id})
  end

  def remove_chat(chat) do
    remove_chat(chat.id)
  end

  def consistent?() do
    GenServer.call(__MODULE__, :assert_consistent)
  end

  ########## callbacks
  def init(table_name) do
    Logger.debug "Starting #{__MODULE__}"
    {:ok, dets} = :dets.open_file(table_name, type: :set)
    ets = :ets.new(@ets_table, [:set, :named_table, :protected]) |> IO.inspect

    :dets.to_ets(dets, ets)
    |> case do
         {:error, err} -> {:stop, err}
         _             -> {:ok, dets}
       end
  end

  def handle_call({:add_chat, chat}, _from, dets) do
    Logger.debug "#{__MODULE__} adding chat #{inspect chat}"
    data = {chat.id, chat}
    :ok  = :dets.insert(dets, data)
    true = :ets.insert(@ets_table, data)
    {:reply, :ok, dets}
  end

  def handle_call({:remove_chat, chat_id}, _from, dets) do
    Logger.debug "#{__MODULE__} removing chat #{chat_id}"
    :ok = :dets.delete(dets, chat_id)
    true = :ets.delete(@ets_table, chat_id)
    {:reply, :ok, dets}
  end

  def handle_call(:assert_consistent, _from, dets) do
    dets_chats = :dets.foldl(fn ({chat_id, chat}, acc) -> Map.put(acc, chat_id, chat) end, %{}, dets)
    ets_chats = :ets.foldl(fn {chat_id, chat}, acc -> Map.put(acc, chat_id, chat) end, %{}, @ets_table)
    result = Map.equal?(dets_chats, ets_chats)
    {:reply, result, dets}
  end

  def terminate(_reason, {dets, _ets}) do
    :ok = :dets.close(dets)
  end

end
