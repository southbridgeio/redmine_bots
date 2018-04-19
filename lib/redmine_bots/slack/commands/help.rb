module RedmineBots::Slack::Commands
  class Help < Base
    responds_to :help

    def call
      reply(text: help_message)
    end

    private

    def help_message
      RedmineBots::Slack::Bot.commands.map { |command| "#{command.names.join(', ')} - #{command.description}" }.join("\n")
    end
  end
end
