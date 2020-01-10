module RedmineBots::Telegram::Tdlib
  class CloseChat < Command
    def call(chat_id)
      client.get_chat(chat_id).then do |chat|
        case chat.type
        when TD::Types::ChatType::BasicGroup
          fetch_robot_ids.then { |*robot_ids| close_basic_group(chat, robot_ids) }.flat
        when TD::Types::ChatType::Supergroup
          close_super_group(chat.type)
        else
          raise 'Unsupported chat type'
        end
      end.flat
    end

    private

    def fetch_robot_ids
      Promises.zip(
          Promises.future { Setting.find_by(name: 'plugin_redmine_bots').value['telegram_bot_id'].to_i },
          client.get_me.then(&:id)
      )
    end

    def close_basic_group(chat, robot_ids)
      client.get_basic_group_full_info(chat.type.basic_group_id).then do |group_info|
        bot_id, robot_id = robot_ids
        bot_member_ids, regular_member_ids = group_info.members.partition { |m| m.user_id.in?(robot_ids) }.map do |arr|
          arr.map(&:user_id)
        end
        member_ids = (regular_member_ids + (bot_member_ids & [bot_id]) + (bot_member_ids & [robot_id]))
        member_ids.reduce(Promises.fulfilled_future(nil)) do |promise, member_id|
          promise.then { delete_member(chat.id, member_id) }.flat
        end
      end.flat
    end

    def close_super_group(chat_type)
      client.delete_supergroup(chat_type.supergroup_id)
    end

    def delete_member(chat_id, user_id)
      client.set_chat_member_status(chat_id, user_id, ChatMemberStatus::Left.new)
    end
  end
end
