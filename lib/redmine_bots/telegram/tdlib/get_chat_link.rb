module RedmineBots::Telegram::Tdlib
  class GetChatLink < Command
    def call(chat_id)
      @client.on_ready do |client|
        client.broadcast_and_receive('@type' => 'generateChatInviteLink', 'chat_id' => chat_id)
      end
    end
  end
end
