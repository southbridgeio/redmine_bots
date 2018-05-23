require File.expand_path('../../../test_helper', __FILE__)

class RedmineBots::Telegram::BotTest < ActiveSupport::TestCase
  fixtures :users, :email_addresses, :roles

  let(:bot_token) { 'token' }

  context '/start' do
    setup do
      @telegram_message = ActionController::Parameters.new(
        from: { id:         123,
                username:   'dhh',
                first_name: 'David',
                last_name:  'Haselman' },
        chat: { id: 123,
                type: 'private' },
        text: '/start'
      )

      @bot_service = RedmineBots::Telegram::Bot.new(bot_token, @telegram_message)
    end

    context 'without user' do
      setup do
        RedmineBots::Telegram::Bot::MessageSender
            .expects(:call)
            .with(
              chat_id: 123,
              message: I18n.t('redmine_bots.telegram.bot.start.instruction_html'),
              bot_token: bot_token
            )
      end

      should 'create telegram account' do
        assert_difference('TelegramAccount.count') do
          @bot_service.call
        end

        telegram_account = TelegramAccount.last
        assert_equal 123, telegram_account.telegram_id
        assert_equal 'dhh', telegram_account.username
        assert_equal 'David', telegram_account.first_name
        assert_equal 'Haselman', telegram_account.last_name
      end

      should 'update telegram account' do
        telegram_account = TelegramAccount.create(telegram_id: 123, username: 'test', first_name: 'f', last_name: 'l')

        assert_no_difference('TelegramAccount.count') do
          @bot_service.call
        end

        telegram_account.reload

        assert_equal 'dhh', telegram_account.username
        assert_equal 'David', telegram_account.first_name
        assert_equal 'Haselman', telegram_account.last_name
      end
    end

    context 'group' do
      setup do
        @telegram_message = ActionController::Parameters.new(
          from: { id:         123,
                  username:   'abc',
                  first_name: 'Antony',
                  last_name:  'Brown' },
          chat: { id: -123,
                  type: 'group' },
          text: '/start'
        )

        @bot_service = RedmineBots::Telegram::Bot.new(bot_token, @telegram_message)
      end

      should 'send message about private command' do
        RedmineBots::Telegram::Bot::MessageSender
          .expects(:call)
          .with(
            chat_id: -123,
            message: I18n.t('redmine_bots.telegram.bot.group.private_command'),
            bot_token: bot_token
          )
        @bot_service.call
      end
    end
  end

  context '/help' do
    context 'private' do
      setup do
        @telegram_message = ActionController::Parameters.new(
          from: { id:         123,
                  username:   'abc',
                  first_name: 'Antony',
                  last_name:  'Brown' },
          chat: { id: 123,
                  type: 'private' },
          text: '/help'
        )

        @bot_service = RedmineBots::Telegram::Bot.new(bot_token, @telegram_message)
      end

      should 'send help for private chat' do
        text = <<~TEXT
          /start - #{I18n.t('redmine_bots.telegram.bot.private.help.start')}
          /connect - #{I18n.t('redmine_bots.telegram.bot.private.help.connect')}
          /help - #{I18n.t('redmine_bots.telegram.bot.private.help.help')}
          /token - #{I18n.t('redmine_bots.telegram.bot.private.help.token')}
        TEXT

        message = text.chomp
        RedmineBots::Telegram::Bot::MessageSender
          .expects(:call)
          .with(
            chat_id: 123,
            message: message,
            bot_token: bot_token
          )

        @bot_service.call
      end
    end

    context 'group' do
      setup do
        @telegram_message = ActionController::Parameters.new(
          from: { id:         123,
                  username:   'abc',
                  first_name: 'Antony',
                  last_name:  'Brown' },
          chat: { id: -123,
                  type: 'group' },
          text: '/help'
        )

        @bot_service = RedmineBots::Telegram::Bot.new(bot_token, @telegram_message)
      end

      should 'send help for private chat' do
        text = <<~TEXT
          #{I18n.t('redmine_bots.telegram.bot.group.no_commands')}
          /start - #{I18n.t('redmine_bots.telegram.bot.private.help.start')}
          /connect - #{I18n.t('redmine_bots.telegram.bot.private.help.connect')}
          /help - #{I18n.t('redmine_bots.telegram.bot.private.help.help')}
          /token - #{I18n.t('redmine_bots.telegram.bot.private.help.token')}
        TEXT

        message = text.chomp
        RedmineBots::Telegram::Bot::MessageSender
          .expects(:call)
          .with(
            chat_id: -123,
            message: message,
            bot_token: bot_token
          )

        @bot_service.call
      end
    end
  end
end
