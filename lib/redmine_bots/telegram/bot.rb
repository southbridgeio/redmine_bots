# frozen_string_literal: true

require 'telegram/bot'

module RedmineBots::Telegram
  class Bot
    class IgnoredError
      IDENTIFIERS = ['bot was blocked', 'bot was kicked', 'user is deactivated', "bot can't initiate conversation with a user", 'chat not found'].freeze

      def self.===(error)
        error.is_a?(Telegram::Bot::Exceptions::ResponseError) && IDENTIFIERS.any? { |i| i.in?(error.message) }
      end
    end

    attr_accessor :default_keyboard

    def initialize(api:, throttle:, async_handler_class: AsyncHandler)
      @api = api
      @throttle = throttle
      @async_handler_class = async_handler_class
      @handlers = Set.new
      @persistent_commands = Set.new
      self.default_keyboard = ::Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    end

    def handle_update(payload)
      RedmineBots::Telegram.set_locale

      action = UserAction.from_payload(payload)

      persistent_commands.each do |command_class|
        command = command_class.retrieve(action.from_id)
        next unless command

        command.resume!(action: action)
        return
      end

      handlers.each { |h| h.call(action: action, bot: self) if h.match?(action) }
    end

    def send_message(chat_id:, **params)
      params = { parse_mode: 'HTML', disable_web_page_preview: true }.merge(params)
      handle_errors { throttle.apply(chat_id) { api.send_message(chat_id: chat_id, **params) } }
    end

    def get_chat(chat_id:)
      handle_errors { throttle.apply(chat_id) { api.get_chat(chat_id: chat_id) } }
    end

    def edit_message_text(chat_id:, **params)
      handle_errors { throttle.apply(chat_id) { api.edit_message_text(chat_id: chat_id, **params) } }
    end

    def promote_chat_member(chat_id:, **params)
      handle_errors { throttle.apply(chat_id) { api.promote_chat_member(chat_id: chat_id, **params) } }
    end

    def get_file(chat_id:, file_id:)
      handle_errors { throttle.apply(chat_id) { api.get_file(file_id: file_id) } }
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

    def register_persistent_command(command_class)
      @persistent_commands << command_class
    end

    def commands
      handlers.select(&:command?)
    end

    private

    attr_reader :api, :throttle, :async_handler_class, :handlers, :persistent_commands

    def log(message)
      Rails.logger.info("RedmineBots: #{message}")
    end

    def handle_errors
      yield
    rescue IgnoredError => e
      log("Ignored error #{e.class}: #{e.message}")
    end
  end
end
