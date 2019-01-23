module RedmineBots::Telegram::Tdlib
  class RenameChat < Command
    def call(chat_id, new_title)
      connect.then { client.set_chat_title(chat_id, new_title) }.flat
    end
  end
end
