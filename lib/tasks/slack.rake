namespace :redmine_bots do
  # bundle exec rake redmine_bots:slack PID_DIR='tmp/pids'
  desc "Runs slack bot process (options: default PID_DIR='tmp/pids')"
  task slack: :environment do
    $stdout.reopen(Rails.root.join('log', 'redmine_bots', 'slack.log'), "a") if Rails.env.production?

    RedmineBots::Utils.daemonize(:slack_bot, &RedmineBots::Slack::Bot.method(:run))
  end
end