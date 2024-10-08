# 0.5.6

* Add compatibility with Redmine 5.1
* Fix showing errors

# 0.5.5

* Add functionality for processing photos from telegram

# 0.5.4

* Fix set bot permissions
* Remove Sidekiq Cron job for Telegram proxy worker

# 0.5.3

* Add step 3 to Telegram client authorization
* Adapt tdlib commands for new version

# 0.5.2

* Merge old 'update' branch

# 0.5.1

* Fix problem with telegram_id exceeding int.

# 0.5.0

* Use supergroup chats
* Refactor telegram commands
* Support persistent commands
* Update tdlib, remove proxy support

# 0.4.1

* Fix tdlib proxy
* Fix AddBot command
* Fix robot_id detection
* Release ActiveRecord connections in concurrent-ruby threads
* Remove ruby 2.7.0 from build matrix
* Update sidekiq-rate-limiter

# 0.4.0

* Handle Faraday::ClientError in MessageSender
* Handle deactivated user error in message sender
* Force ipv4 when using proxy
* Improve proxy availability check
* Close supergroups properly
* Rescue from chat not found errors
* Increase sleep time for flood error
* Handle forbidden errors in message sender
* Use sleep time from error data
* Add zh-TW locale
* Handle "message not modified errors"
* Increase rate limits, add exponential retry
* Support tdlib 1.6

# 0.3.1

* Fix Rails 4 support

# 0.3.0

* Hidden secret fields in settings
* Adapt tdlib commands for new version
* Add plugins deprecation warning
* Add proxy pool
* Add bot to robot contacts automatically
* Use unified proxies for bot and tdlib

# 0.2.0

* Add view telegram account permission
* Add webhook secret param
* Adapt for Redmine 4
* Fix locales in telegram client authentication
* Fix getUpdate hint on settings page

# 0.1.0

* Initial release
