module RedmineBots::Telegram::Tdlib
  class RenameChat < Command
    def call(chat_id, new_title)
      client.set_chat_title(chat_id: chat_id, title: new_title)
    end
  end
end
