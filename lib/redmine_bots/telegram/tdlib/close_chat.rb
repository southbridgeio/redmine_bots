module RedmineBots::Telegram::Tdlib
  class CloseChat < Command
    def call(chat_id)
      Promises.zip(
        Promises.future { Setting.find_by(name: 'plugin_redmine_bots').value['telegram_bot_id'].to_i },
        client.get_me.then(&:id)
      ).then do |*robot_ids|
        client.get_chat(chat_id).then do |chat|
          client.get_basic_group_full_info(chat.type.basic_group_id)
        end.flat.then do |group_info|
          member_ids = group_info.members.reject { |m| m.user_id.in?(robot_ids) }.map(&:user_id) + robot_ids
          Promises.zip(*member_ids.map { |member_id| delete_member(chat_id, member_id) })
        end.flat
      end.flat
    end

    private

    def delete_member(chat_id, user_id)
      client.set_chat_member_status(chat_id, user_id, ChatMemberStatus::Left.new)
    end
  end
end
