module RedmineBots::Telegram
  module BotCommand
    module Help
      def help
        message = private_command? ? private_help_message : group_help_message
        send_message(message)
      end

      private

      def private_commands
        %w(start connect help token)
      end

      def group_commands
        %w(help)
      end

      def private_help_message
        help_command_list(private_commands)
      end

      def help_command_list(list, namespace: 'redmine_bots.telegram', type: 'private')
        list.map do |command|
          %(/#{command} - #{I18n.t("#{namespace}.bot.#{type}.help.#{command}")}).chomp
        end.join("\n")
      end

      def group_help_message
        [I18n.t('redmine_bots.telegram.bot.group.no_commands'), private_help_message].join("\n")
      end
    end
  end
end
