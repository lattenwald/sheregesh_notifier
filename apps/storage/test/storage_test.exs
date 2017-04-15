defmodule StorageTest do
  use ExUnit.Case
  doctest Storage

  test "code loaded" do
    assert Code.ensure_loaded?(Storage)
  end

  test "initial state is empty" do
    assert Storage.get_latest() == %{}
  end

  test "adding and removing data" do
    assert Storage.get_latest == %{}
    assert Storage.consistent?()

    date1 = Timex.to_date({2017, 1, 1})
    date2 = Timex.to_date({2017, 1, 2})
    assert :inserted == Storage.store({{:key1, date1}, 11})
    assert Storage.consistent?()
    assert :inserted == Storage.store({{:key2, date1}, 21})
    assert Storage.get_latest == %{key1: {date1, 11}, key2: {date1, 21}}
    assert Storage.consistent?()

    assert :exists   == Storage.store({{:key1, date1}, 31})
    assert Storage.get_latest == %{key1: {date1, 11}, key2: {date1, 21}}
    assert Storage.consistent?()

    assert :inserted == Storage.store({{:key1, date2}, 12})
    assert Storage.get_latest == %{key1: {date2, 12}, key2: {date1, 21}}
    assert Storage.consistent?()
  end
end
