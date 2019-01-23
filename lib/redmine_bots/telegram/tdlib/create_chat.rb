module RedmineBots::Telegram::Tdlib
  class CreateChat < Command
    def call(title, user_ids)
      connect.then do
        user_ids.reduce(Promises.fulfilled_future(true)) do |promise, id|
          promise.then { client.get_user(id) }.flat
        end.then do
          client.create_new_basic_group_chat(user_ids, title).then do |chat|
            client.toggle_basic_group_administrators(chat.type.basic_group_id, false)
          end.flat
        end
      end
    end
  end
end
