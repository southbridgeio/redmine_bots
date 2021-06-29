module RedmineBots::Telegram::Tdlib
  class AddToChat < Command
    def call(chat_id, user_name)
      client.search_public_chat(user_name).then do |user_chat|
        client.get_user(user_chat.id).then { client.add_chat_member(chat_id, user_chat.id, nil) }.flat
      end.flat
    end
  end
end
