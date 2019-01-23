module RedmineBots::Telegram::Tdlib
  class GetUser < Command
    def call(user_id)
      connect.then { client.get_user(user_id) }.flat
    end
  end
end
