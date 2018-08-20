module RedmineBots
  module Telegram

    class Bot::UpdateSignInMessage
      def self.call(*args)
        new(*args).call
      end

      def initialize(telegram_account, message_id)
        @telegram_account, @message_id = telegram_account, message_id
      end

      def call
        bot = ::Telegram::Bot::Client.new(RedmineBots::Telegram.bot_token)

        bot.api.edit_message_text(chat_id: @telegram_account.telegram_id,
                                  message_id: @message_id,
                                  text: "✅ *#{I18n.t('redmine_bots.telegram.bot.login.success')}*",
                                  parse_mode: 'Markdown')
      end
    end
  end
end
