def init_bot
  Process.daemon(true, true) if Rails.env.production?

  tries = 0
  begin
    tries += 1

    if ENV['PID_DIR']
      pid_dir = ENV['PID_DIR']
      PidFile.new(piddir: pid_dir, pidfile: 'telegram-chat-bot.pid')
    else
      PidFile.new(piddir: Rails.root.join('tmp', 'pids'), pidfile: 'telegram-chat-bot.pid')
    end

  rescue PidFile::DuplicateProcessError => e
    LOG.error "#{e.class}: #{e.message}"
    pid = e.message.match(/Process \(.+ - (\d+)\) is already running./)[1].to_i

    LOG.info "Kill process with pid: #{pid}"

    Process.kill('HUP', pid)
    if tries < 4
      LOG.info 'Waiting for 5 seconds...'
      sleep 5
      LOG.info 'Retry...'
      retry
    end
  end

  Signal.trap('TERM') do
    at_exit { LOG.error 'Aborted with TERM signal' }
    abort
  end

  LOG.info 'Start daemon...'

  token = Setting.plugin_redmine_bots['telegram_bot_token']

  unless token.present?
    LOG.error 'Telegram Bot Token not found. Please set it in the plugin config web-interface.'
    exit
  end

  LOG.info 'Telegram Bot: Connecting to telegram...'

  require 'telegram/bot'

  bot = RedmineBots::Telegram.init_bot
  bot.api.setWebhook(url: '') # reset webhook
  bot
end

namespace :redmine_bots do
  # bundle exec rake telegram_common:bot PID_DIR='tmp/pids'
  desc "Runs telegram bot process (options: default PID_DIR='tmp/pids')"
  task telegram: :environment do
    LOG = Rails.env.production? ? Logger.new(Rails.root.join('log/telegram_bots', 'bot.log')) : Logger.new(STDOUT)

    bot = init_bot
    begin
      bot.listen do |message|
        next unless message.is_a?(Telegram::Bot::Types::Message)
        RedmineBots::Telegram.update_manager.handle_message(message)
      end
    rescue => e
      ExceptionNotifier.notify_exception(e) if defined?(ExceptionNotifier)
      LOG.error "GLOBAL #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
    end
  end

  task migrate_to_single_bot: :environment do
    settings_chat = Setting.find_by_name(:plugin_redmine_chat_telegram)
    settings_intouch = Setting.find_by_name(:plugin_redmine_intouch)
    settings_2fa = Setting.find_by_name(:plugin_redmine_2fa)

    setting_name = [settings_chat, settings_intouch, settings_2fa].first(&:present?).try(:name)
    return if setting_name.blank?

    p "Using bot from #{setting_name}"

    old_settings = Setting.public_send(setting_name)
    bot_token = old_settings[setting_name == 'plugin_redmine_intouch' ? 'telegram_bot_token' : 'bot_token']

    settings = Setting.find_by(name: 'plugin_redmine_bots')

    settings.value = settings.value.merge('telegram_bot_token' => bot_token)
    settings.save
  end
end