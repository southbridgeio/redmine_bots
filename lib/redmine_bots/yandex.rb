module RedmineBots
  module Yandex
    API_URL = 'https://botapi.messenger.yandex.net/bot/v1/'.freeze
    WEB_CHAT_URL = 'https://yandex.ru/chat#/chats/'.freeze

    class Error < StandardError; end

    BOT_MUTEX = Mutex.new
    INIT_MUTEX = Mutex.new

    class << self
      def settings
        Setting.find_by_name(:plugin_redmine_bots)&.value || {}
      end

      def bot_token
        settings['yandex_bot_token'].presence
      end

      def enabled?
        bot_token.present?
      end

      def client
        Client.new(token: bot_token)
      end

      def bot
        BOT_MUTEX.synchronize { @bot ||= Bot.new }
      end

      def init
        INIT_MUTEX.synchronize do
          return if @bot_initialized

          bot.register_handler(Handlers::ConnectCommand.new)
          @bot_initialized = true
        end
      end

      def set_locale
        I18n.locale = Setting['default_language']
      end

      def bot_name
        settings['yandex_bot_name'].presence
      end

      def webhook_url
        "#{Setting.protocol}://#{Setting.host_name}/yandex/api/web_hook/#{webhook_secret}"
      end

      def webhook_secret
        Digest::SHA256.hexdigest("yandex:#{Rails.application.secret_key_base}")
      end

      def web_chat_url(chat_id)
        "#{WEB_CHAT_URL}#{CGI.escape(chat_id.to_s)}"
      end

      # Yandex 360 addresses users by login rather than by a numeric id. The
      # login comes from the user's YandexAccount — the Redmine e-mail is
      # deliberately NOT used as a fallback, so that a coincidental address
      # match can never pull the wrong person into a chat.
      def login_for(principal)
        return unless principal.is_a?(::User)
        return if principal.anonymous? || principal.locked?

        principal.yandex_account&.login
      end

      def logins_for(principals)
        Array(principals).filter_map { |p| login_for(p) }.uniq
      end

      def logger
        @logger ||= Logger.new(Rails.root.join('log', 'redmine_bots', 'yandex.log'))
      end
    end
  end
end
