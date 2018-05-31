module RedmineBots
  module Telegram
    class Bot::Authenticate
      AUTH_TIMEOUT = 60.minutes

      def self.call(user, auth_data, context:)
        new(user, auth_data, context: context).call
      end

      def initialize(user, auth_data, context:)
        @user, @auth_data, @context = user, Hash[auth_data.sort_by { |k, _| k }], context
      end

      def call
        return failure(I18n.t('redmine_bots.telegram.bot.login.errors.not_logged')) unless @user.logged?
        return failure(I18n.t('redmine_bots.telegram.bot.login.errors.hash_invalid')) unless hash_valid?
        return failure(I18n.t('redmine_bots.telegram.bot.login.errors.hash_outdated')) unless up_to_date?

        case @context
        when '2fa_connection'
          telegram_account = prepare_telegram_account(model_class: Redmine2FA::TelegramConnection)
          return failure(I18n.t('redmine_bots.telegram.bot.login.errors.wrong_account')) unless telegram_account
        when 'account_connection'
          telegram_account = prepare_telegram_account(model_class: TelegramAccount)
          return failure(I18n.t('redmine_bots.telegram.bot.login.errors.wrong_account')) unless telegram_account
          telegram_account.assign_attributes(@auth_data.slice('first_name', 'last_name', 'username'))
        else
          return failure('Invalid context')
        end

        if telegram_account.save
          success(telegram_account)
        else
          failure(I18n.t('redmine_bots.telegram.bot.login.errors.not_persisted'))
        end
      end

      private

      def prepare_telegram_account(model_class:)
        telegram_account = model_class.find_by(user_id: @user.id)

        if telegram_account.present?
          if telegram_account.telegram_id
            unless @auth_data['id'].to_i == telegram_account.telegram_id
              return nil
            end
          else
            telegram_account.telegram_id = @auth_data['id']
          end
        else
          telegram_account = model_class.find_or_initialize_by(telegram_id: @auth_data['id'])
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

      def hash_valid?
        Utils.auth_hash(@auth_data) == @auth_data['hash']
      end

      def up_to_date?
        Time.at(@auth_data['auth_date'].to_i) > Time.now - AUTH_TIMEOUT
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
