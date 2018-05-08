log_dir = Rails.root.join('log/redmine_bots')
tmp_dir = Rails.root.join('tmp/redmine_bots')

FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)
FileUtils.mkdir_p(tmp_dir) unless Dir.exist?(tmp_dir)

require 'telegram/bot'

# Rails 5.1/Rails 4
reloader = defined?(ActiveSupport::Reloader) ? ActiveSupport::Reloader : ActionDispatch::Reloader
reloader.to_prepare do
  Faraday::Adapter.register_middleware redmine_bots: RedmineBots::Telegram::Bot::FaradayAdapter

  Telegram::Bot.configure do |config|
    config.adapter = :redmine_bots
  end
end

Redmine::Plugin.register :redmine_bots do
  name 'Redmine Bots'
  url 'https://github.com/centosadmin/redmine_bots'
  description 'This is a platform for building Redmine bots'
  version '0.1.0'
  author 'Southbridge'
  author_url 'https://github.com/centosadmin'

  settings(
    default: {
     'slack_oauth_token' => '',
     'slack_bot_oauth_token' => '',
     'slack_client_id' => '',
     'slack_client_secret' => '',
     'slack_verification_token' => '',
    },
    partial: 'settings/redmine_bots'
  )
end
