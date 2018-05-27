module RedmineBots::Telegram::Tdlib
  module DependencyProviders
    module Client
      def client
        LazyObject.new do
          settings = Setting.plugin_redmine_bots
          TD::Api.set_log_file_path(Rails.root.join('log', 'redmine_bots', 'tdlib.log').to_s)
          config = {
              api_id: settings['telegram_api_id'],
              api_hash: settings['telegram_api_hash'],
              database_directory: Rails.root.join('tmp', 'redmine_bots', 'tdlib', 'db').to_s,
              files_directory: Rails.root.join('tmp', 'redmine_bots', 'tdlib', 'files').to_s,
          }
          proxy = {
              '@type' => 'proxySocks5',
              'server' => settings['tdlib_proxy_server'],
              'port' => settings['tdlib_proxy_port'],
              'username' => settings['tdlib_proxy_user'],
              'password' => settings['tdlib_proxy_password']
          }
          TD::Client.new(**(settings['tdlib_use_proxy'] ? { proxy: proxy } : {}), **config)
        end
      end
    end

    module Authenticate
      include Client

      def authenticate
        RedmineBots::Telegram::Tdlib::Authenticate.new(client, logger)
      end
    end

    module CreateChat
      include Client

      def create_chat
        RedmineBots::Telegram::Tdlib::CreateChat.new(client)
      end
    end

    module GetChatLink
      include Client

      def get_chat_link
        RedmineBots::Telegram::Tdlib::GetChatLink.new(client)
      end
    end

    module GetMe
      include Client

      def get_me
        RedmineBots::Telegram::Tdlib::GetMe.new(client)
      end
    end

    module CloseChat
      include Client

      def close_chat
        RedmineBots::Telegram::Tdlib::CloseChat.new(client)
      end
    end

    module RenameChat
      include Client

      def rename_chat
        RedmineBots::Telegram::Tdlib::RenameChat.new(client)
      end
    end

    module GetChat
      include Client

      def get_chat
        RedmineBots::Telegram::Tdlib::GetChat.new(client)
      end
    end

    module ToggleChatAdmin
      include Client

      def toggle_chat_admin
        RedmineBots::Telegram::Tdlib::ToggleChatAdmin.new(client)
      end
    end

    module AddBot
      include Client

      def add_bot
        RedmineBots::Telegram::Tdlib::AddBot.new(client)
      end
    end

    module GetUser
      include Client

      def get_user
        RedmineBots::Telegram::Tdlib::GetUser.new(client)
      end
    end
  end
end
