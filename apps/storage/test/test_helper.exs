table = :storage_test
table |> Atom.to_string |> File.rm |> IO.inspect
Application.put_env(:storage, :table, table)
Application.ensure_all_started(:storage)
ExUnit.start()
