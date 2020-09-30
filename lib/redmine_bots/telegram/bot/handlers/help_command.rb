module RedmineBots::Telegram::Bot::Handlers
  class HelpCommand
    include HandlerBehaviour

    def private?
      true
    end

    def group?
      true
    end

    def name
      'help'
    end

    def description
      I18n.t('redmine_bots.telegram.bot.private.help.help')
    end

    def allowed?(_user)
      true
    end

    def command?
      true
    end

    def call(bot:, action:)
      message = RedmineBots::Telegram::Bot::HelpMessage.new(bot, action).to_s

      keyboard = action.user ? bot.default_keyboard : ::Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)

      bot.async.send_message(chat_id: action.chat_id, text: message, reply_markup: keyboard.to_json)
    end
  end
end
