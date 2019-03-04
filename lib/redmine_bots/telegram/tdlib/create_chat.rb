module RedmineBots::Telegram::Tdlib
  class CreateChat < Command
    def call(title, user_ids)
      Promises.zip(*user_ids.map(&client.method(:get_user))).then do
        client.create_new_basic_group_chat(user_ids, title).then do |chat|
          client.toggle_basic_group_administrators(chat.type.basic_group_id, false).then { chat }
        end.flat
      end.flat
    end
  end
end
