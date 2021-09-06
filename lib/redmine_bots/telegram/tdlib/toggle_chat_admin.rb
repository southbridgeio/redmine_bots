module RedmineBots::Telegram::Tdlib
  class ToggleChatAdmin < Command
    def call(chat_id, user_id, admin = true)
      status =
          if admin
            TD::Types::ChatMemberStatus::Administrator.new(
                can_post_messages: true,
                can_be_edited: true,
                can_change_info: true,
                can_edit_messages: true,
                can_delete_messages: true,
                can_invite_users: true,
                can_restrict_members: true,
                can_pin_messages: true,
                can_promote_members: true,
                custom_title: 'Redmine admin'
            )
          else
            TD::Types::ChatMemberStatus::Member.new
          end
      client.get_user(user_id: user_id).then { client.set_chat_member_status(chat_id: chat_id, user_id: user_id, status: status) }.flat
    end
  end
end
