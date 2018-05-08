module RedmineBots::Telegram
  class Bot::FaradayAdapter < Faraday::Adapter::NetHttp
    def net_http_connection(env)
      if proxy = fetch_proxy_from_settings
        Net::HTTP::Proxy(proxy[:server], proxy[:port], proxy[:user], proxy[:password])
      else
        Net::HTTP
      end.new(env[:url].hostname, env[:url].port || (env[:url].scheme == 'https' ? 443 : 80))
    end

    private

    def fetch_proxy_from_settings
      settings = Setting.plugin_redmine_bots
      return unless settings['bot_use_proxy']
      {
          server: settings['bot_proxy_server'],
          port: settings['bot_proxy_port'],
          user: settings['bot_proxy_user'],
          password: settings['bot_proxy_password']
      }
    end
  end
end
