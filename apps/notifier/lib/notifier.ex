defmodule Notifier do
  require Logger

  def notify(key, date, data) do
    # Logger.debug "#{__MODULE__} ::: #{key} #{date} #{data}"
    for c <- Tgchats.list_chats do
      notify(c.id, key, date, data)
    end
  end

  def notify(chat_id, key, date, data) do
    spawn fn ->
      {:ok, _} = Nadia.send_message(
        chat_id, """
        *#{key}* #{date}

        #{data}
        """,
      parse_mode: "Markdown"
    )
    end
  end

end
