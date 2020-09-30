class RedmineBots::Telegram::Bot
  class HelpMessage
    def initialize(bot, action)
      @bot = bot
      @action = action
    end

    def to_s
      commands = action.private? ? bot.commands.select(&:private?) : bot.commands.select(&:group?)

      commands.select { |command| command.allowed?(action.user) }.map do |command|
        %[/#{command.name} - #{command.description}].chomp
      end.join("\n")
    end

    private

    attr_reader :bot, :action
  end
end
