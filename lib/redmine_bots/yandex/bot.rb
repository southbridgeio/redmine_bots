module RedmineBots
  module Yandex
    class Bot
      def initialize
        @handlers = Set.new
      end

      def register_handler(handler)
        @handlers << handler
      end

      def handlers
        @handlers
      end

      def handle_update(payload)
        RedmineBots::Yandex.set_locale

        update = Update.new(payload)
        return if update.from_bot?

        handlers.each { |handler| handler.call(update: update, bot: self) if handler.match?(update) }
      end

      def send_message(text, chat_id: nil, login: nil, **params)
        RedmineBots::Yandex.client.send_text(text: text, chat_id: chat_id, login: login, **params)
      rescue RedmineBots::Yandex::Error => e
        RedmineBots::Yandex.logger.error("Unable to send a message: #{e.message}")
        nil
      end

      def reply(update, text, **params)
        if update.private?
          send_message(text, login: update.from_login, **params)
        else
          send_message(text, chat_id: update.chat_id, **params)
        end
      end
    end
  end
end
