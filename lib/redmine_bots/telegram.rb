module RedmineBots::Telegram
  def self.set_locale
    I18n.locale = Setting['default_language']
  end

  def self.bot_token
    Setting.find_by_name(:plugin_redmine_bots).value['telegram_bot_token']
  end

  def self.webhook_secret
    Digest::SHA256.hexdigest(Rails.application.secrets[:secret_key_base])
  end

  def self.update_manager
    @update_manager ||= UpdateManager.new
  end

  def self.tdlib_client
    settings = Setting.find_by_name(:plugin_redmine_bots).value
    TD::Api.set_log_file_path(Rails.root.join('log', 'redmine_bots', 'tdlib.log').to_s)
    config = {
        api_id: settings['telegram_api_id'],
        api_hash: settings['telegram_api_hash'],
        database_directory: Rails.root.join('tmp', 'redmine_bots', 'tdlib', 'db').to_s,
        files_directory: Rails.root.join('tmp', 'redmine_bots', 'tdlib', 'files').to_s,
    }

    TD::Client.new(**config)
  end

  def self.init_bot
    token = Setting.plugin_redmine_bots['telegram_bot_token']
    self_info = {}

    if Setting.plugin_redmine_bots['telegram_phone_number'].present?
      self_info = Tdlib::GetMe.call.rescue do
        raise 'Please, set correct settings for plugin RedmineBots::Telegram'
      end.value!.to_h
    end

    robot_id = self_info['id']

    bot      = Telegram::Bot::Client.new(token)
    bot_info = bot.api.get_me['result']
    bot_name = bot_info['username']

    RedmineBots::Telegram::Tdlib::AddBot.(bot_name) if robot_id

    plugin_settings = Setting.find_by(name: 'plugin_redmine_bots')

    plugin_settings_hash = plugin_settings.value
    plugin_settings_hash['telegram_bot_name'] = bot_name
    plugin_settings_hash['telegram_bot_id'] = bot_info['id']
    plugin_settings_hash['telegram_robot_id'] = robot_id
    plugin_settings.value = plugin_settings_hash

    plugin_settings.save

    bot
  end
end
