module RedmineBots::Telegram::Tdlib
  class CloseChat < Command
    def call(chat_id)
      client.get_chat(chat_id: chat_id).then do |chat|
        client.delete_chat(chat_id: chat_id)
      end.flat
    end
  end
end
