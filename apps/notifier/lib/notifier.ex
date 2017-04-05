defmodule Notifier do
  require Logger

  def notify(key, date, data) do
    # Logger.debug "#{__MODULE__} ::: #{key} #{date} #{data}"
    for c <- Tgchats.list_chats do
      notify(c, key, date, data)
    end
  end

  def notify(chat, key, date, data) do
    opts = [parse_mode: "Markdown", disable_web_page_preview: true]
    opts = case chat.type do
             "private" -> opts
             _         -> [{:disable_notification, true} | opts]
           end

    send_message(
      chat, """
      *#{key}* #{date}

      #{data}
      """,
      opts
    )
  end

  def send_message(chat, message, opts \\ []) do
    spawn fn -> {:ok, _} = Nadia.send_message(chat.id, message, opts) end
  end

end
