module RedmineBots::Telegram::Tdlib
  class CloseChat < Command
    def call(chat_id)
      @client.on_ready do |client|
        me = client.fetch('@type' => 'getMe')
        bot_id = Setting.find_by(name: 'plugin_redmine_bots').value['telegram_bot_id'].to_i

        chat = client.fetch('@type' => 'getChat', 'chat_id' => chat_id)

        group_info = client.fetch('@type' => 'getBasicGroupFullInfo',
                                     'basic_group_id' => chat.dig('type', 'basic_group_id')
        )
        return if group_info['@type'] == 'error'

        group_info['members'].map { |m| m['user_id'] }.each do |user_id|
          delete_member(chat_id, user_id) unless user_id.in?([me['id'], bot_id])
        end

        delete_member(chat_id, me['id'])
        delete_member(chat_id, bot_id)
      end
    end

    private

    def delete_member(chat_id, user_id)
      @client.fetch('@type' => 'setChatMemberStatus',
                                    'chat_id' => chat_id,
                                    'user_id' => user_id,
                                    'status' => { '@type' => 'chatMemberStatusLeft' })
    end
  end
end
