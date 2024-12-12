module RedmineBots
  module Telegram
    class Bot::Authenticate
      AUTH_TIMEOUT = 60.minutes

      attr_reader :login_error

      def self.call(user, auth_data, context:)
        new(user, auth_data, context: context).call
      end

      def initialize(user, auth_data, context:)
        @user, @auth_data, @context = user, Hash[auth_data.to_h.sort_by { |k, _| k }], context
      end

      def call
        return failure(I18n.t('redmine_bots.telegram.bot.login.errors.not_logged')) unless @user.logged?
        return failure(I18n.t('redmine_bots.telegram.bot.login.errors.hash_invalid')) unless hash_valid?
        return failure(I18n.t('redmine_bots.telegram.bot.login.errors.hash_outdated')) unless up_to_date?

        case @context
        when '2fa_connection'
          telegram_account = prepare_telegram_account(model_class: RedmineTwoFa::TelegramConnection)
          return failure(login_error) unless telegram_account
        when 'account_connection'
          telegram_account = prepare_telegram_account(model_class: TelegramAccount)
          return failure(login_error) unless telegram_account
          telegram_account.assign_attributes(@auth_data.slice('first_name', 'last_name', 'username'))
        else
          return failure('Invalid context')
        end

        TelegramAccount.transaction do
          return failure(I18n.t('redmine_bots.telegram.bot.login.errors.not_persisted')) unless telegram_account.save

          if create_account_after_2fa(telegram_account)
            return success(telegram_account)
          end

          raise ActiveRecord::Rollback
        end

        failure(login_error)
      end

      private

      attr_writer :login_error

      def prepare_telegram_account(model_class:)
        telegram_account = model_class.find_by(user_id: @user.id)

        if telegram_account.present?
          if telegram_account.telegram_id
            if @auth_data['id'].to_i != telegram_account.telegram_id
              self.login_error = I18n.t('redmine_bots.telegram.bot.login.errors.wrong_account')
              return nil
            end
          else
            telegram_account.telegram_id = @auth_data['id']
          end
        else
          telegram_account = model_class.find_or_initialize_by(telegram_id: @auth_data['id'])
          if telegram_account.user_id
            if telegram_account.user_id != @user.id
              self.login_error = (I18n.t('redmine_bots.telegram.bot.login.errors.account_exists'))
              return nil
            end
          else
            telegram_account.user_id = @user.id
          end
        end
        telegram_account
      end

      def create_account_after_2fa(telegram_account)
        return true if telegram_account.is_a?(TelegramAccount)

        telegram_account_2fa = prepare_telegram_account(model_class: TelegramAccount)

        return false if telegram_account_2fa.blank?

        telegram_account_2fa.assign_attributes(@auth_data.slice('first_name', 'last_name', 'username'))

        telegram_account_2fa.save
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
