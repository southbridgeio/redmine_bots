module RedmineBots::Telegram::Tdlib
  class CreateChat < Command
    def call(title, user_ids)
      Promises.zip(*user_ids.map { |id| client.get_user(user_id: id) }).then do
        client.create_new_supergroup_chat(**supergroup_chat_params(title)).then do |chat|
          client.add_chat_members(chat_id: chat.id, user_ids: user_ids).then do
            client.set_chat_permissions(chat_id: chat.id, permissions: permissions).then { chat }
          end.flat
        end.flat
      end.flat
    end

    private

    def permissions
      ChatPermissions.new(
        can_send_basic_messages: true,
        can_send_audios: true,
        can_send_documents: true,
        can_send_photos: true,
        can_send_videos: true,
        can_send_video_notes: true,
        can_send_voice_notes: true,
        can_send_polls: true,
        can_send_other_messages: true,
        can_add_link_previews: true,
        can_send_media_messages: true,
        can_change_info: false,
        can_invite_users: false,
        can_pin_messages: false,
        can_create_topics: false
      )
    end

    def supergroup_chat_params(title)
      {
        title: title,
        is_channel: false,
        description: '',
        location: nil,
        is_forum: false,
        message_auto_delete_time: 0,
        for_import: true
      }
    end
  end
end
