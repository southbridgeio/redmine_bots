module RedmineBots
  module Telegram
    class Bot::AuthenticateByToken
      def self.call(*args)
        new(*args).call
      end

      def initialize(user, token, context:, sign_in_message_id:)
        @user, @token, @context, @sign_in_message_id = user, token, context, sign_in_message_id
      end

      def call
        return failure(I18n.t('redmine_bots.telegram.bot.login.errors.not_logged')) if @user.anonymous?

        case @context
        when '2fa_connection'
          telegram_account = prepare_telegram_account(model_class: Redmine2FA::TelegramConnection)
        when 'account_connection'
          telegram_account = prepare_telegram_account(model_class: TelegramAccount)
        else
          return failure('Invalid context')
        end

        return failure(I18n.t('redmine_bots.telegram.bot.login.errors.wrong_account')) unless telegram_account

        if telegram_account.save
          ::RedmineBots::Telegram::Bot::UpdateSignInMessage.(telegram_account, @sign_in_message_id) if @sign_in_message_id
          success(telegram_account)
        else
          failure(I18n.t('redmine_bots.telegram.bot.login.errors.not_persisted'))
        end
      rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIssuerError, JWT::InvalidIatError
        failure(I18n.t('redmine_bots.telegram.bot.login.errors.invalid_token'))
      end

      private

      def prepare_telegram_account(model_class:)
        telegram_data = Jwt.decode_token(@token).first
        telegram_id = telegram_data['telegram_id'].to_i
        telegram_account = model_class.find_by(user_id: @user.id)

        if telegram_account.present?
          if telegram_account.telegram_id
            unless telegram_id == telegram_account.telegram_id
              return nil
            end
          else
            telegram_account.telegram_id = telegram_id
          end
        else
          telegram_account = model_class.find_or_initialize_by(telegram_id: telegram_id)
          if telegram_account.user_id
            unless telegram_account.user_id == @user.id
              return nil
            end
          else
            telegram_account.user_id = @user.id
          end
        end
        telegram_account
      end

      def success(value)
        Result.new(true, value)
      end

      def failure(value)
        Result.new(false, value)
      end

      def bot
        @bot ||= ::Telegram::Bot::Client.new(RedmineBots::Telegram.bot_token)
      end
    end
  end
end
