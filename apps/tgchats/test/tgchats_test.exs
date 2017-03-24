defmodule TgchatsChatsTest do
  use ExUnit.Case
  doctest Tgchats

  test "code loaded" do
    assert Code.ensure_loaded?(Tgchats)
  end

  test "initial state is empty" do
    assert Tgchats.list_chats() == []
  end

  test "adding and removing chat" do
    chat = %{
      id: 1, type: "private", username: "testuname",
      first_name: "test fname", last_name: "test lname"
    }

    assert Tgchats.list_chats == []
    assert Tgchats.add_chat(chat) == :ok
    assert Tgchats.list_chats == [chat]
    assert Tgchats.get_chat(1) == chat
    assert Tgchats.get_chat(2) == nil

    assert Tgchats.remove_chat(chat) == :ok
    assert Tgchats.list_chats == []
    assert Tgchats.get_chat(1) == nil

    assert Tgchats.add_chat(chat) == :ok
    assert Tgchats.list_chats == [chat]

    assert Tgchats.remove_chat(1) == :ok
    assert Tgchats.list_chats == []
    assert Tgchats.get_chat(1) == nil
  end

end
