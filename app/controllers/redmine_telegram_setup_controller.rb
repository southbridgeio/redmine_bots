class RedmineTelegramSetupController < ApplicationController
  include RedmineBots::Telegram::Tdlib

  def step_1
  end

  def step_2
    RedmineBots::Telegram::Tdlib.wrap do
      promise = RedmineBots::Telegram::Tdlib::Authenticate.(params).rescue do |error|
        redirect_to plugin_settings_path('redmine_bots'), alert: error.message
      end

      RedmineBots::Telegram::Tdlib.permit_concurrent_loads { promise.wait! }
    end
  end

  def step_3
    RedmineBots::Telegram::Tdlib.wrap do
      promise = RedmineBots::Telegram::Tdlib::Authenticate.(params).rescue do |error|
        redirect_to plugin_settings_path('redmine_bots'), alert: error.message
      end

      RedmineBots::Telegram::Tdlib.permit_concurrent_loads { promise.wait! }
    end
  end

  def authorize
    RedmineBots::Telegram::Tdlib.wrap do
      promise = RedmineBots::Telegram::Tdlib::Authenticate.(params).then do
        RedmineBots::Telegram::Tdlib::FetchAllChats.call
      end.flat.then do
        ActiveRecord::Base.connection_pool.with_connection { save_phone_settings(phone_number: params['phone_number']) }
        redirect_to plugin_settings_path('redmine_bots'), notice: t('redmine_bots.telegram.authorize.success')
      end

      RedmineBots::Telegram::Tdlib.permit_concurrent_loads { promise.wait! }
    end
  rescue TD::Error => error
    redirect_to plugin_settings_path('redmine_bots'), alert: error.message
  end

  def reset
    save_phone_settings(phone_number: nil)
    FileUtils.rm_rf(Rails.root.join('tmp', 'redmine_bots', 'tdlib'))
    redirect_to plugin_settings_path('redmine_bots')
  end

  def bot_init
    web_hook_url = "https://#{Setting.host_name}/telegram/api/web_hook/#{RedmineBots::Telegram.webhook_secret}"

    bot = RedmineBots::Telegram.init_bot
    bot.api.setWebhook(url: web_hook_url)

    redirect_to plugin_settings_path('redmine_bots'), notice: t('redmine_2chat.bot.authorize.success')
  end

  def bot_deinit
    token = Setting.plugin_redmine_bots['telegram_bot_token']
    bot   = Telegram::Bot::Client.new(token)
    bot.api.setWebhook(url: '')
    redirect_to plugin_settings_path('redmine_bots'), notice: t('redmine_2chat.bot.deauthorize.success')
  end

  private

  def save_phone_settings(phone_number:)
    Setting.send('plugin_redmine_bots=', Setting.plugin_redmine_bots.merge({'telegram_phone_number' => phone_number.to_s}).to_h)
  end
end
