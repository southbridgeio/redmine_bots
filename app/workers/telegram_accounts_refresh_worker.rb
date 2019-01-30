class TelegramAccountsRefreshWorker
  include Sidekiq::Worker

  sidekiq_options queue: :telegram

  def perform
    TelegramAccount.find_each do |account|
      user_data = RedmineBots::Telegram::Tdlib::GetUser.(account.telegram_id).value!.to_h
      account.update_attributes(user_data.slice(*%w[username first_name last_name]))
    end
  end
end
