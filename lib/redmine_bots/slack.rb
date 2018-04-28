module RedmineBots::Slack
  def self.configured?
    false
  end

  def self.client
    ::Slack::Web::Client.new
  end

  def self.robot_client
    ::Slack::Web::Client.new(token: Setting.plugin_redmine_bots['slack_oauth_token'])
  end

  def self.bot_client
    ::Slack::Web::Client.new(token: Setting.plugin_redmine_bots['slack_bot_oauth_token'])
  end
end
