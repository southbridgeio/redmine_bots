log_dir = Rails.root.join('log/redmine_bots')

FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)

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