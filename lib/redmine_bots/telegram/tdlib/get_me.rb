module RedmineBots::Telegram::Tdlib
  class GetMe < Command
    def call
      @client.on_ready do |client|
        client.fetch('@type' => 'getMe')
      end
    end
  end
end
