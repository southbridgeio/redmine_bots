module RedmineBots::Telegram::Tdlib
  class CreateChat < Command
    def call(title, user_ids)
      puts title
      puts user_ids
      Promises.zip(*user_ids.map { |id| client.get_user(user_id: id) }).then do
        client.create_new_supergroup_chat(title: title, is_channel: false, description: '', location: nil).then do |chat|
          client.add_chat_members(chat_id: chat.id, user_ids: user_ids).then do
            client.set_chat_permissions(chat_id: chat.id, permissions: permissions).then { chat }
          end.flat
        end.flat
      end.flat
    end

    private

    def permissions
      ChatPermissions.new(can_send_messages: true,
                          can_send_media_messages: true,
                          can_send_polls: true,
                          can_send_other_messages: true,
                          can_add_web_page_previews: true,
                          can_change_info: false,
                          can_invite_users: false,
                          can_pin_messages: false)
    end
  end
end
