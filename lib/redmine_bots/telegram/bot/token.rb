class RedmineBots::Telegram::Bot
  class Token
    include Singleton

    def to_s
      Setting.find_by_name(:plugin_redmine_bots).value['telegram_bot_token']
    end
  end
end
