module RedmineBots::Telegram::Tdlib
  class GetMe < Command
    def call
      client.get_me
    end
  end
end
