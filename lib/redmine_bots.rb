module RedmineBots
  def self.deprecated_plugins
    Redmine::Plugin.all.map(&:id) & %i[redmine_telegram_common redmine_chat_telegram]
  end
end
