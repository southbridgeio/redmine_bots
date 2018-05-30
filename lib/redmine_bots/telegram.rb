module RedmineBots::Telegram
  extend Tdlib::DependencyProviders::GetMe
  extend Tdlib::DependencyProviders::AddBot

  def self.set_locale
    I18n.locale = Setting['default_language']
  end

  def self.bot_token
    Setting.find_by_name(:plugin_redmine_bots).value['telegram_bot_token']
  end

  def self.update_manager
    @update_manager ||= UpdateManager.new
  end

  def self.init_bot
    token = Setting.plugin_redmine_bots['telegram_bot_token']
    self_info = get_me.call

    unless self_info['@type'] == 'user'
      raise 'Please, set correct settings for plugin RedmineBots::Telegram'
    end

    robot_id = self_info['id']

    bot      = Telegram::Bot::Client.new(token)
    bot_info = bot.api.get_me['result']
    bot_name = bot_info['username']

    until bot_name.present?
      sleep 60

      bot      = Telegram::Bot::Client.new(token)
      bot_info = bot.api.get_me['result']
      bot_name = bot_info['username']
    end

    add_bot.(bot_info['id'])

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
