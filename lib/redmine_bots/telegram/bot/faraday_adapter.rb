module RedmineBots::Telegram
  class Bot::FaradayAdapter < Faraday::Adapter::EMHttp
    def configure_proxy(*)
      settings = Setting.find_by_name(:plugin_redmine_bots).value
      return unless settings['bot_use_proxy']

      proxy = TelegramProxy.alive.first
      return unless proxy

      options[:proxy] = {
          host: proxy.host,
          port: proxy.port,
          type: proxy.protocol,
          authorization: [proxy.user, proxy.password]
      }
    end
  end
end
