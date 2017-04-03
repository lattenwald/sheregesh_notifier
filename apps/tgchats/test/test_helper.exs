table = :tgchats_test
table |> Atom.to_string |> File.rm
Application.put_env(:tgchats, :table, table)
Application.ensure_all_started(:tgchats)
ExUnit.start()
