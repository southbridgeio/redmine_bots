module RedmineBots::Telegram::Bot::Handlers
  class ConnectCommand
    include HandlerBehaviour

    def private?
      true
    end

    def command?
      true
    end

    def name
      'connect'
    end

    def allowed?(user)
      user.anonymous?
    end

    def description
      I18n.t('redmine_bots.telegram.bot.private.help.connect')
    end

    def call(bot:, action:)
      if action.user.active?
        message = I18n.t('redmine_bots.telegram.bot.connect.already_connected')
      else
        message = I18n.t('redmine_bots.telegram.bot.connect.login_link', link: "#{Setting.protocol}://#{Setting.host_name}/telegram/login")
      end

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
