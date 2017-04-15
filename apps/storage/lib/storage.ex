defmodule Storage do
  use GenServer
  require Logger

  @ets_table __MODULE__

  def start_link(table_name) do
    GenServer.start_link(__MODULE__, table_name, name: __MODULE__)
  end

  def store(data) do
    GenServer.call(__MODULE__, {:store, data})
  end

  def get_latest() do
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
    :ets.foldl(folder, %{}, @ets_table)
  end

  def consistent?() do
    GenServer.call(__MODULE__, :assert_consistent)
  end

  ###### callbacks
  def init(table_name) do
    Logger.debug "Starting #{__MODULE__} with table #{inspect table_name}"
    {:ok, dets} = :dets.open_file(table_name, type: :set)
    ets = :ets.new(@ets_table, [:set, :named_table, :protected]) |> IO.inspect

    :dets.to_ets(dets, ets)
    |> case do
         {:error, err} -> {:stop, err}
         _             -> {:ok, dets}
       end
  end

  def handle_call({:store, data={key, _}}, _from, dets) do
    case :dets.lookup(dets, key) do
      [{^key, _}] ->
        # Logger.debug "already exists: #{inspect data}"
        {:reply, :exists, dets}
      [] ->
        # Logger.debug "storing: #{inspect data}"
        :ok = :dets.insert(dets, data)
        true = :ets.insert(@ets_table, data)
        {:reply, :inserted, dets}
    end
  end

  def handle_call(:assert_consistent, _from, dets) do
    dets_data = :dets.foldl(fn ({key, val}, acc) -> Map.put(acc, key, val) end, %{}, dets)
    ets_data = :ets.foldl(fn {key, val}, acc -> Map.put(acc, key, val) end, %{}, @ets_table)
    result = Map.equal?(dets_data, ets_data)
    {:reply, result, dets}
  end

  def terminate(_reason, table), do: :dets.close(table)

end
