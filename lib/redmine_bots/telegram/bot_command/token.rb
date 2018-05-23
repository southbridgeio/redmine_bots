module RedmineBots::Telegram
  module BotCommand
    module Token
      def token
        token = Jwt.encode(telegram_id: chat_id)
        send_message("Please, follow link: #{Setting.protocol}://#{Setting.host_name}/telegram/check_jwt?token=#{token}")
      end
    end
  end
end