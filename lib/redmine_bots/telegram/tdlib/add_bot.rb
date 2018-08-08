module RedmineBots::Telegram::Tdlib
  class AddBot < Command
    def call(bot_id)
      @client.on_ready do |client|
        chat = client.fetch('@type' => 'createPrivateChat', 'user_id' => bot_id)
        client.fetch('@type' => 'sendBotStartMessage',
                                              'bot_user_id' => bot_id,
                                              'chat_id' => chat['id'])
      end
    end
  end
end
