module RedmineBots
  module Yandex
    module Handlers
      class ConnectCommand
        COMMANDS = %w[start connect].freeze

        def match?(update)
          update.private? && update.command.in?(COMMANDS)
        end

        def call(update:, bot:)
          login = update.from_login

          if login.blank?
            bot.reply(update, I18n.t('redmine_bots.yandex.connect.no_login'))
            return
          end

          account = YandexAccount.for_login(login)

          if account&.verified?
            bot.reply(update, I18n.t('redmine_bots.yandex.connect.already_connected', user: account.user.name))
          else
            bot.reply(update, I18n.t('redmine_bots.yandex.connect.link', link: connect_url(update)))
          end
        end

        private

        def connect_url(update)
          token = RedmineBots::Jwt.encode(yandex_login: update.from_login,
                                          yandex_guid: update.from_guid,
                                          yandex_display_name: update.display_name)

          "#{Setting.protocol}://#{Setting.host_name}/yandex/connect/#{token}"
        end
      end
    end
  end
end
