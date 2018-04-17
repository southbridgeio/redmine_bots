Redmine::Plugin.register :redmine_messengers_common do
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
    },
    partial: 'settings/redmine_bots'
  )
end