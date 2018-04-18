module RedmineBots::Telegram
  module BotCommand
    module Start
      def start
        update_account

        message = if account.user.present?
                    I18n.t('redmine_bots.telegram.bot.start.hello')
                  else
                    I18n.t('redmine_bots.telegram.bot.start.instruction_html')
                  end

        send_message(message)
      end

      private

      def update_account
        account.assign_attributes username: user.username,
                                  first_name: user.first_name,
                                  last_name: user.last_name

        write_log_about_new_user if logger && account.new_record?

        account.save!
      end

      def write_log_about_new_user
        logger.info "New telegram_user #{user.first_name} #{user.last_name} @#{user.username} added!"
      end
    end
  end
end
