module RedmineBots::Telegram::Tdlib
  class CreateChat < Command
    def call(title, user_ids)
      @client.on_ready(timeout: 5) do |client|
        user_ids.each do |id|
          client.fetch('@type' => 'getUser', 'user_id' => id)
        end

        sleep 1

        chat = client.fetch('@type' => 'createNewBasicGroupChat',
                                            'title' => title,
                                            'user_ids' => user_ids)

        sleep 1

        client.fetch('@type' => 'toggleBasicGroupAdministrators',
                                     'basic_group_id' => chat.dig('type', 'basic_group_id'),
                                     'everyone_is_administrator' => false)
        chat
      end
    end
  end
end
