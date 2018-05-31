module RedmineBots
  class Telegram::Bot::SendSignInLink
    include RedmineBots::Telegram::Jwt

    def self.call(user, context:)
      new(user, context: context).call
    end

    def initialize(user, context:)
      @user, @context = user, context
    end

    def call
      telegram_account =
          case @context
          when '2fa_connection'
            @user.telegram_account
          when 'account_connection'
            @user.telegram_connection
          else
            nil
          end
      return unless telegram_account

      token = encode(telegram_id: telegram_account.telegram_id)
      message_params = {
          chat_id: telegram_account.telegram_id,
          message: "#{I18n.t('redmine_bots.telegram.bot.login.follow_link')}: #{Setting.protocol}://#{Setting.host_name}/telegram/check_jwt?token=#{token}",
          bot_token: RedmineBots::Telegram.bot_token
      }

      RedmineBots::Telegram::Bot::MessageSender.call(message_params)
    end
  end
end
