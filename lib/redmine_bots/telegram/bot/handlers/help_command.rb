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
      commands = action.private? ? bot.commands.select(&:private?) : bot.commands.select(&:group?)

      message = commands.select { |command| command.allowed?(action.user) }.map do |command|
        %[/#{command.name} - #{command.description}].chomp
      end.join("\n")

      bot.async.send_message(chat_id: action.chat_id, text: message)
    end
  end
end
