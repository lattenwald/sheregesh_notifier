defmodule Storage do
  use GenServer
  require Logger

  def start_link(table_name) do
    GenServer.start_link(__MODULE__, table_name, name: __MODULE__)
  end

  def store(data) do
    GenServer.call(__MODULE__, {:store, data})
  end

  def get_latest() do
    GenServer.call(__MODULE__, :get_latest)
  end

  ###### callbacks
  def init(table_name) do
    Logger.debug "Starting #{__MODULE__} with table #{inspect table_name}"
    {:ok, table} = :dets.open_file(table_name, type: :set)
    {:ok, table}
  end

  def handle_call({:store, data={key, _}}, _from, table) do
    case :dets.lookup(table, key) do
      [{^key, _}] ->
        # Logger.debug "already exists: #{inspect data}"
        {:reply, :exists, table}
      [] ->
        # Logger.debug "storing: #{inspect data}"
        :dets.insert(table, data)
        {:reply, :inserted, table}
    end
  end

  def handle_call(:get_latest, _from, table) do
    folder = fn {{key, date}, data}, acc ->
      case Map.fetch(acc, key) do
        :error -> Map.put(acc, key, {date, data})
        {:ok, {old_date, _}} ->
          if Timex.after?(date, old_date) do
            Map.put(acc, key, {date, data})
          else
            acc
          end
      end
    end
    data = :dets.foldl(folder, %{}, table)
    {:reply, data, table}
  end

  def terminate(_reason, table), do: :dets.close(table)

end
