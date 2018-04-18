class TelegramAccountsRefreshWorker
  include Sidekiq::Worker
  include RedmineBots::Telegram::Tdlib::DependencyProviders::GetUser

  sidekiq_options queue: :telegram

  def perform
    TelegramAccount.all.each do |account|
      user_data = get_user.(account.telegram_id)
      account.update_attributes(user_data.slice(*%w[username first_name last_name]))
    end
  end
end
