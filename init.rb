log_dir = Rails.root.join('log/redmine_bots')
tmp_dir = Rails.root.join('tmp/redmine_bots')

FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)
FileUtils.mkdir_p(tmp_dir) unless Dir.exist?(tmp_dir)

require 'telegram/bot'

# Rails 5.1/Rails 4
reloader = defined?(ActiveSupport::Reloader) ? ActiveSupport::Reloader : ActionDispatch::Reloader
reloader.to_prepare do
  require_dependency 'redmine_bots/telegram'

  paths = '/lib/redmine_bots/telegram/{patches/*_patch,hooks/*_hook}.rb'

  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end
end

Rails.application.config.eager_load_paths += Dir.glob("#{Rails.application.config.root}/plugins/redmine_bots/{lib,app/workers,app/models,app/controllers,lib/redmine_bots/telegram/{patches/*_patch,hooks/*_hook}}")

Sidekiq::Logging.logger = Logger.new(Rails.root.join('log', 'sidekiq.log'))
Sidekiq::Cron::Job.create(name:  'Telegram proxy monitoring',
                          cron:  '*/3 * * * *',
                          class: 'TelegramProxyMonitoringWorker')

Redmine::Plugin.register :redmine_bots do
  name 'Redmine Bots'
  url 'https://github.com/southbridgeio/redmine_bots'
  description 'This is a platform for building Redmine bots'
  version '0.5.0'
  author 'Southbridge'
  author_url 'https://github.com/southbridgeio'

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

  permission :view_telegram_account_info, {}
end

RedmineBots::Telegram.init
