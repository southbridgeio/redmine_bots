def init_bot
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

    RedmineBots::Utils.daemonize(:telegram_bot, logger: LOG) do
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
  end

  task migrate_from_telegram_common: :environment do
    class TelegramCommonAccount < ActiveRecord::Base
    end

    TelegramAccount.transaction do
      TelegramCommonAccount.all.each do |old_account|
        next if TelegramAccount.find_by(telegram_id: old_account.telegram_id)
        TelegramAccount.create!(old_account.slice(:telegram_id, :user_id, :username, :first_name, :last_name))
      end

      telegram_common_settings = Setting.find_by_name(:plugin_redmine_telegram_common)

      settings = Setting.find_or_initialize_by(name: 'plugin_redmine_bots')

      settings.value = settings.value.to_h.merge(%w[bot_token api_id api_hash].map { |name| { "telegram_#{name}" => YAML.load(telegram_common_settings[:value])[name] } }.reduce(:merge))
      settings.save!

      FileUtils.copy_entry(Rails.root.join('tmp', 'redmine_telegram_common', 'tdlib'), Rails.root.join('tmp', 'redmine_bots', 'tdlib'))

      puts 'Successfully transferred accounts and settings'
    end
  end
end