module RedmineBots::Telegram
  class Container
    extend Dry::Container::Mixin

    register :client do
      settings = Setting.find_by_name(:plugin_redmine_bots).value
      TD::Api.set_log_file_path(Rails.root.join('log', 'redmine_bots', 'tdlib.log').to_s)
      config = {
        api_id: settings['telegram_api_id'],
        api_hash: settings['telegram_api_hash'],
        database_directory: Rails.root.join('tmp', 'redmine_bots', 'tdlib', 'db').to_s,
        files_directory: Rails.root.join('tmp', 'redmine_bots', 'tdlib', 'files').to_s,
      }

      client = TD::Client.new(**config)

      if settings['tdlib_use_proxy']
        proxy = TD::Types::ProxyType::Socks5.new(username: settings['tdlib_proxy_user'],
                                                 password: settings['tdlib_proxy_password'])
        client.add_proxy(settings['tdlib_proxy_server'], settings['tdlib_proxy_port'], proxy, true).wait!
      end

      client
    end
  end
end
