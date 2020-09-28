module RedmineBots::Telegram::Bot::Handlers
  class StartCommand
    include HandlerBehaviour

    def private?
      true
    end

    def command?
      true
    end

    def name
      'start'
    end

    def allowed?(_user)
      true
    end

    def description
      I18n.t('redmine_bots.telegram.bot.private.help.start')
    end

    def call(bot:, action:)
      message = action.user ? hello_message : instruction_message

      bot.async.send_message(chat_id: action.chat_id, text: message)
    end

    private

    def hello_message
      I18n.t('redmine_bots.telegram.bot.start.hello')
    end

    def instruction_message
      I18n.t('redmine_bots.telegram.bot.start.instruction_html')
    end
  end
end
