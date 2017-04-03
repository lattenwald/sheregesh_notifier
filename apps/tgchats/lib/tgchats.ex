defmodule Tgchats do
  use GenServer
  require Logger

  def start_link(table_name) do
    GenServer.start_link(__MODULE__, table_name, name: __MODULE__)
  end

  def add_chat(chat) do
    GenServer.cast(__MODULE__, {:add_chat, chat})
  end

  def list_chats() do
    GenServer.call(__MODULE__, :list_chats)
  end

  def get_chat(chat_id) do
    GenServer.call(__MODULE__, {:get_chat, chat_id})
  end

  def remove_chat(id) when is_number(id) do
    GenServer.cast(__MODULE__, {:remove_chat, id})
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
    ets = :ets.new(table_name, [:set, :protected])

    :dets.to_ets(dets, ets)
    |> case do
         {:error, err} -> {:stop, err}
         _             -> {:ok, {dets, ets}}
       end
  end

  def handle_cast({:add_chat, chat}, state={dets, ets}) do
    Logger.debug "#{__MODULE__} adding chat #{inspect chat}"
    data = {chat.id, chat}
    :ok  = :dets.insert(dets, data)
    true = :ets.insert(ets, data)
    {:noreply, state}
  end

  def handle_cast({:remove_chat, chat_id}, state={dets, ets}) do
    Logger.debug "#{__MODULE__} removing chat #{chat_id}"
    :ok = :dets.delete(dets, chat_id)
    true = :ets.delete(ets, chat_id)
    {:noreply, state}
  end

  def handle_call(:list_chats, _from, state={_, ets}) do
    chats = :ets.foldl(fn {_chat_id, chat}, acc -> [chat|acc] end, [], ets)
    {:reply, chats, state}
  end

  def handle_call({:get_chat, chat_id}, _from, state={_, ets}) do
    chat = case :ets.lookup(ets, chat_id) do
             [{^chat_id, c}] -> c
             _ -> nil
           end
    {:reply, chat, state}
  end

  def handle_call(:assert_consistent, _from, state={dets, ets}) do
    dets_chats = :dets.foldl(fn ({chat_id, chat}, acc) -> Map.put(acc, chat_id, chat) end, %{}, dets)
    ets_chats = :ets.foldl(fn {chat_id, chat}, acc -> Map.put(acc, chat_id, chat) end, %{}, ets)
    result = Map.equal?(dets_chats, ets_chats)
    {:reply, result, state}
  end

  def terminate(_reason, {dets, _ets}) do
    :ok = :dets.close(dets)
  end

end
