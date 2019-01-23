module RedmineBots::Telegram::Tdlib
  class GetMe < Command
    def call
      connect.then { client.get_me }.flat
    end
  end
end
