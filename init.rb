log_dir = Rails.root.join('log/redmine_bots')
tmp_dir = Rails.root.join('tmp/redmine_bots')

FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)
FileUtils.mkdir_p(tmp_dir) unless Dir.exist?(tmp_dir)

require 'telegram/bot'
require 'sidekiq/throttled'
require "sidekiq/throttled/web"

register_after_redmine_initialize_proc =
  if Redmine::VERSION::MAJOR >= 5
    Rails.application.config.public_method(:after_initialize)
  else
    reloader = defined?(ActiveSupport::Reloader) ? ActiveSupport::Reloader : ActionDispatch::Reloader
    reloader.public_method(:to_prepare)
  end
register_after_redmine_initialize_proc.call do
  paths = '/lib/redmine_bots/{patches/*_patch,telegram/{patches/*_patch,hooks/*_hook},yandex/hooks/*_hook}.rb'

  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end
end

User.prepend(RedmineBots::Patches::UserPatch) unless User.ancestors.include?(RedmineBots::Patches::UserPatch)

Rails.application.config.eager_load_paths += Dir.glob("#{Rails.application.config.root}/plugins/redmine_bots/{lib,app/workers,app/models,app/controllers,lib/redmine_bots/telegram/{patches/*_patch,hooks/*_hook}}")

Redmine::Plugin.register :redmine_bots do
  name 'Redmine Bots'
  url 'https://github.com/southbridgeio/redmine_bots'
  description 'This is a platform for building Redmine bots'
  version '0.7.0'
  author 'Southbridge'
  author_url 'https://github.com/southbridgeio'

  settings(
    default: {
     'slack_oauth_token' => '',
     'slack_bot_oauth_token' => '',
     'slack_client_id' => '',
     'slack_client_secret' => '',
     'slack_verification_token' => '',
     'yandex_bot_token' => '',
    },
    partial: 'settings/redmine_bots'
  )

  permission :view_telegram_account_info, {}
end

Sidekiq.configure_server do |config|
  require 'sidekiq/throttled/middlewares/server'

  config.server_middleware do |chain|
    chain.prepend(Sidekiq::Throttled::Middlewares::Server)
  end
end

RedmineBots::Telegram.init
RedmineBots::Yandex.init
