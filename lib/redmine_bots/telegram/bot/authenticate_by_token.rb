module RedmineBots
  module Telegram
    class Bot::AuthenticateByToken
      def self.call(*args)
        new(*args).call
      end

      def initialize(user, token)
        @user, @token = user, token
      end

      def call
        return failure(I18n.t('redmine_bots.telegram.bot.login.errors.not_logged')) if @user.anonymous?
        telegram_data = Jwt.decode_token(@token).first
        telegram_id = telegram_data['telegram_id'].to_i
        telegram_account = TelegramAccount.find_by(user_id: @user.id)

        if telegram_account.present?
          if telegram_account.telegram_id
            unless telegram_id == telegram_account.telegram_id
              return failure(I18n.t('redmine_bots.telegram.bot.login.errors.wrong_account'))
            end
          else
            telegram_account.telegram_id = telegram_id
          end
        else
          telegram_account = TelegramAccount.find_or_initialize_by(telegram_id: telegram_id)
          if telegram_account.user_id
            unless telegram_account.user_id == @user.id
              return failure(I18n.t('redmine_bots.telegram.bot.login.errors.wrong_account'))
            end
          else
            telegram_account.user_id = @user.id
          end
        end

        if telegram_account.save
          success(telegram_account)
        else
          failure(I18n.t('redmine_bots.telegram.bot.login.errors.not_persisted'))
        end
      rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIssuerError, JWT::InvalidIatError
        failure(I18n.t('redmine_bots.telegram.bot.login.errors.invalid_token'))
      end

      def success(value)
        Result.new(true, value)
      end

      def failure(value)
        Result.new(false, value)
      end
    end
  end
end
