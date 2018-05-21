[![Build Status](https://travis-ci.org/centosadmin/redmine_bots.svg?branch=master)](https://travis-ci.org/centosadmin/redmine_bots)

# redmine_bots

This plugin provides common stuff to build redmine plugins that involve Slack/Telegram API usage.

## Requirements

* Ruby 2.3+
* Redmine 3.3+

## Telegram

Telegram support includes:

* Common components to interact with Bot API
* Common client commands that utilize [tdlib-ruby](https://github.com/centosadmin/tdlib-ruby)
* [Telegram Login](https://core.telegram.org/widgets/login) to connect Redmine and Telegram accounts

### Tdlib
In order to use tdlib client you need compiled [TDLib](https://github.com/tdlib/td).

  It should be placed it in `redmine_root/vendor` or added to [ldconfig](https://www.systutorials.com/docs/linux/man/8-ldconfig/).

  For CentOS you can use our repositories:

  http://rpms.southbridge.ru/rhel7/stable/x86_64/

  http://rpms.southbridge.ru/rhel6/stable/x86_64/

  And also SRPMS:

  http://rpms.southbridge.ru/rhel7/stable/SRPMS/

  http://rpms.southbridge.ru/rhel6/stable/SRPMS/
  
To make telegram client working you should follow steps:

* Be sure you set correct host in Redmine settings
* Go to the plugin settings page
* Press "Authorize Telegram client" button and follow instructions

### Bot API

It is necessary to register a bot and get its token.
There is a [@BotFather](https://telegram.me/botfather) bot used in Telegram for this purpose.
Type `/start` to get a complete list of available commands.

Type `/newbot` command to register a new bot.
[@BotFather](https://telegram.me/botfather) will ask you to name the new bot. The bot's name must end with the "bot" word.
On success @BotFather will give you a token for your new bot and a link so you could quickly add the bot to the contact list.
You'll have to come up with a new name if registration fails.

Set the Privacy mode to disabled with `/setprivacy`. This will let the bot listen to all group chats and write its logs to Redmine chat archive.

Set bot domain with `/setdomain` for account connection via Telegram Login. Otherwise, you will receive `Bot domain invalid` error on account connection page.

Enter the bot's token on the Plugin Settings page to add the bot to your chat.

To add hints for commands for the bot, use command `/setcommands`. You need to send list of commands with descriptions. You can get this list from command `/help`.

**Bot should be added to contacts of account used to authorize telegram client in plugin.**

Bot can work in two [modes](https://core.telegram.org/bots/api#getting-updates) — getUpdates or WebHooks.

#### getUpdates

To work via getUpdates, you should run bot process `bundle exec rake redmine_bots:telegram`.
This will drop bot WebHook setting.


#### WebHooks

To work via WebHooks, you should go to plugin settings and press button "Initialize bot"
(bot token should be saved earlier, and notice that redmine should work on https)

## Slack

Slack support includes:

* Bot components
* Rake task to daemonize slack bot
* [Sign in with Slack](https://api.slack.com/docs/sign-in-with-slack) to connect Redmine and Slack accounts

In order to use Slack integrations you need to follow these steps:

* Create your own Slack app [here](https://api.slack.com/apps?new_app=1).

* Go to your app page (you can view the list of all your apps [here](https://api.slack.com/apps)) and copy data from *App Credentials* block to plugin settings.

* Create bot user on *Bot users* page.

* Obtain your oauth tokens on *OAuth & Permissions* page and copy it to plugin settings.

* Add redirect url for *Sign in with Slack*: `https://your.redmine.host/slack/sign_in/check`

* Configure app scopes on demand.

* Run bot with `bundle exec rake redmine_bots:slack`

## Migration from redmine_telegram_common

You can transparently migrate your old data (telegram accounts, settings and tdlib db/files) to new DB structure if you used *redmine_telegram_common* before with `bundle exec rake redmine_bots:migrate_from_telegram_common`.


## Author of the Plugin

The plugin is designed by [Southbridge](https://southbridge.io)
