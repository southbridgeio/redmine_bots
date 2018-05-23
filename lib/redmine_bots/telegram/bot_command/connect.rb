module RedmineBots::Telegram
  module BotCommand
    module Connect
      EMAIL_REGEXP = /([^@\s]+@(?:[-a-z0-9]+\.)+[a-z]{2,})/i

      def connect
        message_text = command.text.downcase
        redmine_user = account&.user

        logger.debug 'RedmineBots::Telegram::Bot#connect'
        logger.debug "message_text: #{message_text}"
        logger.debug "redmine_user: #{redmine_user.inspect}"

        if redmine_user.present?
          message = I18n.t('redmine_bots.telegram.bot.connect.already_connected')
        else
          message = I18n.t('redmine_bots.telegram.bot.connect.login_link', link: "#{Setting.protocol}://#{Setting.host_name}/telegram/login")
        end

        send_message(message)
      end
    end
  end
end
