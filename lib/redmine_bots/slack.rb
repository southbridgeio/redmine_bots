module RedmineBots::Slack
  def self.configured?
    false
  end

  def self.web_client
    ::Slack::Web::Client.new(token: Setting.plugin_redmine_bots['slack_oauth_token'])
  end
end
