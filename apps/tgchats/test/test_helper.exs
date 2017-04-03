Application.put_env(:tgchats, :table, :tgchats_test)
Application.ensure_all_started(:tgchats)
ExUnit.start()
