module RedmineBots
  def self.deprecated_plugins
    Redmine::Plugin.all.map(&:id) & %i[redmine_telegram_common redmine_chat_telegram]
  end

  def self.settings(value)
    Setting.find_by_name(:plugin_redmine_bots).value[value]
  end
end
