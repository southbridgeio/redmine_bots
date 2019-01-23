module RedmineBots::Telegram::Tdlib
  class GetChatLink < Command
    def call(chat_id)
      connect.then { client.generate_chat_invite_link(chat_id) }.flat
    end
  end
end
