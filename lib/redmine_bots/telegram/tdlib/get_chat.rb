module RedmineBots::Telegram::Tdlib
  class GetChat < Command
    def call(id)
      @client.on_ready do |client|
        client.fetch('@type' => 'getChat', 'chat_id' => id)
      end
    end
  end
end