module RedmineBots::Telegram::Tdlib
  class GetChat < Command
    def call(id)
      client.get_chat(chat_id: id)
    end
  end
end