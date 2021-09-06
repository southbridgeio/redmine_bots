module RedmineBots::Telegram::Tdlib
  class GetChatLink < Command
    def call(chat_id)
      client.generate_chat_invite_link(chat_id: chat_id)
    end
  end
end
