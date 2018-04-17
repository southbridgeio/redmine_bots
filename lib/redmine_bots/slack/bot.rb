module RedmineBots::Slack
  class Bot < SlackRubyBot::Bot
    def self.instance
      SlackRubyBot::Server.new(token: Setting.plugin_redmine_bots['slack_bot_oauth_token'])
    end

    command 'connect', &Commands::Connect
  end
end
