module RedmineBots::Telegram
  module BotCommand
    module Token
      def token
        token = Jwt.encode(telegram_id: chat_id)
        send_message("#{I18n.t('redmine_bots.telegram.bot.login.follow_link')}: #{Setting.protocol}://#{Setting.host_name}/telegram/check_jwt?token=#{token}")
      end
    end
  end
end