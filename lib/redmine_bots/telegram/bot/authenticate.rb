module RedmineBots::Telegram
  class Bot::Authenticate
    AUTH_TIMEOUT = 60.minutes

    def self.call(user, auth_data)
      new(user, auth_data).call
    end

    def initialize(user, auth_data)
      @user, @auth_data = user, Hash[auth_data.sort_by { |k, _| k }]
    end

    def call
      return failure(I18n.t('redmine_bots.telegram.bot.login.errors.not_logged')) unless @user.logged?
      return failure(I18n.t('redmine_bots.telegram.bot.login.errors.hash_invalid')) unless hash_valid?
      return failure(I18n.t('redmine_bots.telegram.bot.login.errors.hash_outdated')) unless up_to_date?

      telegram_account = TelegramAccount.find_by(user_id: @user.id)

      if telegram_account.present?
        if telegram_account.telegram_id
          unless @auth_data['id'].to_i == telegram_account.telegram_id
            return failure(I18n.t('redmine_bots.telegram.bot.login.errors.wrong_account'))
          end
        else
          telegram_account.telegram_id = @auth_data['id']
        end
      else
        telegram_account = TelegramAccount.find_or_initialize_by(telegram_id: @auth_data['id'])
        if telegram_account.user_id
          unless telegram_account.user_id == @user.id
            return failure(I18n.t('redmine_bots.telegram.bot.login.errors.wrong_account'))
          end
        else
          telegram_account.user_id = @user.id
        end
      end

      telegram_account.assign_attributes(@auth_data.slice(*%w[first_name last_name username]))

      if telegram_account.save
        success(telegram_account)
      else
        failure(I18n.t('redmine_bots.telegram.bot.login.errors.not_persisted'))
      end
    end

    private

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

    class Result
      attr_reader :value

      def initialize(success, value)
        @success, @value = success, value
      end

      def success?
        @success
      end
    end
  end
end
