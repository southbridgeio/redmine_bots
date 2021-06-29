module RedmineBots::Telegram::Tdlib
  class AddToChat < Command
    def call(chat_id, user_name)
      client.search_public_chat(username: user_name).then do |user_chat|
        client.get_user(user_id: user_chat.id).then { client.add_chat_member(chat_id: chat_id, user_id: user_chat.id, forward_limit: nil) }.flat
      end.flat
    end
  end
end
