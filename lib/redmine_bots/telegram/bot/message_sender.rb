module RedmineBots::Telegram
  class Bot
    class MessageSender
      def self.call(params)
        new(params).call
      end

      attr_reader :chat_id, :message, :bot_token, :params

      def initialize(params)
        @message = params.fetch(:message)
        @chat_id = params.fetch(:chat_id)
        @bot_token = params.fetch(:bot_token)
        @params = params.except(:message, :chat_id, :bot_token)
      end

      def call
        message_params = {
          chat_id: chat_id,
          text: message,
          parse_mode: 'HTML',
          disable_web_page_preview: true,
        }.merge(params)

        bot.api.send_message(message_params)
      rescue BotKickedError
        logger.warn("Bot was kicked from chat. Chat Id: #{chat_id}, params: #{params.inspect}")
      end

      private

      def bot
        @bot ||= ::Telegram::Bot::Client.new(bot_token)
      end

      def logger
        @logger ||= Logger.new(Rails.root.join('log/telegram_common',
                                           'message-sender.log'))
      end

      class BotKickedError
        def self.===(e)
          e.is_a?(Telegram::Bot::Exceptions::ResponseError) && e.message.include?('kicked')
        end
      end
    end
  end
end
