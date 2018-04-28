module RedmineBots::Slack
  class Bot < SlackRubyBot::Bot
    @@mutex = Mutex.new
    @@commands = []
    @@handlers = []

    cattr_reader :commands, :handlers

    def self.instance
      Server.new(token: Setting.plugin_redmine_bots['slack_bot_oauth_token'])
    end

    def self.register_commands(*commands)
      @@mutex.synchronize { @@commands |= commands }

      commands.each do |command|
        command.names.each { |name| command(name, &command) }
      end
    end

    def self.register_handlers(*handlers)
      @@mutex.synchronize { @@handlers |= handlers }

      handlers.each do |handler|
        Server.on(handler.event, &handler)
      end
    end

    register_commands Commands::Connect, Commands::Help
  end
end
