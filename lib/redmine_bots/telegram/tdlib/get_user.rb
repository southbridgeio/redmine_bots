module RedmineBots::Telegram::Tdlib
  class GetUser < Command
    def call(user_id)
      client.get_user(user_id: user_id)
    end
  end
end
