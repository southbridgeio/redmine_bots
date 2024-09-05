module RedmineBots::Telegram::Tdlib
  class ToggleChatAdmin < Command
    def call(chat_id, user_id, admin = true)
      status =
        if admin
          TD::Types::ChatMemberStatus::Administrator.new(
            rights: rights,
            can_be_edited: true,
            custom_title: 'Redmine admin'
          )
        else
          TD::Types::ChatMemberStatus::Member.new
        end
      client.get_user(user_id: user_id).then { client.set_chat_member_status(chat_id: chat_id, member_id: message_sender(user_id), status: status) }.flat
    end

    private

    def rights
      TD::Types::ChatAdministratorRights.new(
        can_manage_topics: true,
        can_manage_chat: true,
        can_change_info: true,
        can_post_messages: true,
        can_edit_messages: true,
        can_delete_messages: true,
        can_invite_users: true,
        can_restrict_members: true,
        can_pin_messages: true,
        can_promote_members: true,
        can_manage_video_chats: true,
        can_post_stories: false,
        can_edit_stories: false,
        can_delete_stories: false,
        is_anonymous: false
      )
    end

    def message_sender(user_id)
      TD::Types::MessageSender::User.new(user_id: user_id)
    end
  end
end
