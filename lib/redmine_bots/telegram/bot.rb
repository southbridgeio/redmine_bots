# frozen_string_literal: true

require 'telegram/bot'

module RedmineBots::Telegram
  class Bot
    class IgnoredError
      IDENTIFIERS = ['bot was blocked', 'user is deactivated', "bot can't initiate conversation with a user", 'chat not found'].freeze

      def self.===(error)
        error.is_a?(Telegram::Bot::Exceptions::ResponseError) && IDENTIFIERS.any? { |i| i.in?(error.message) }
      end
    end

    def initialize(api:, throttle:, async_handler_class: AsyncHandler)
      @api = api
      @throttle = throttle
      @async_handler_class = async_handler_class
      @handlers = Set.new
    end

    def handle_update(payload)
      RedmineBots::Telegram.set_locale

      action = UserAction.from_payload(payload)
      handlers.each { |h| h.call(action: action, bot: self) if h.match?(action) }
    end

    def send_message(chat_id:, **params)
      handle_errors { throttle.apply(chat_id) { api.send_message(chat_id: chat_id, **params) } }
    end

    def get_chat(chat_id:)
      handle_errors { throttle.apply(chat_id) { api.get_chat(chat_id: chat_id) } }
    end

    def edit_message_text(chat_id:, **params)
      handle_errors { throttle.apply(chat_id) { api.edit_message_text(chat_id: chat_id, **params) } }
    end

    def set_webhook
      webhook_url = "https://#{Setting.host_name}/telegram/api/web_hook/#{webhook_secret}"
      api.set_webhook(url: webhook_url)
    end

    def webhook_secret
      Digest::SHA256.hexdigest(Rails.application.secrets[:secret_key_base])
    end

    def async
      async_handler_class.new(self)
    end

    def register_handler(handler)
      @handlers << handler
    end

    def commands
      handlers.select(&:command?)
    end

    private

    attr_reader :api, :throttle, :async_handler_class, :handlers

    def log(message)
      Rails.logger.tagged(self.class.name) { |logger| logger.info(message) }
    end

    def handle_errors
      yield
    rescue IgnoredError => e
      log("Ignored error #{e.class}: #{e.message}")
    end
  end
end
