module RedmineBots::Telegram::Tdlib
  class ToggleChatAdmin < Command
    def call(chat_id, user_id, admin = true)
      status =
        if admin
          { '@type' => 'chatMemberStatusAdministrator',
            'can_change_info' => true,
            'can_edit_messages' => true,
            'can_delete_messages' => true,
            'can_invite_users' => true,
            'can_restrict_members' => true,
            'can_pin_messages' => true,
            'can_promote_members' => true }
        else
          { '@type' => 'chatMemberStatusMember' }
        end
      @client.on_ready do |client|
        client.fetch('@type' => 'getUser', 'user_id' => user_id)
        client.fetch('@type' => 'setChatMemberStatus',
                                     'chat_id' => chat_id,
                                     'user_id' => user_id,
                                     'status' => status)
      end
    end
  end
end
