class TelegramAccountsRefreshWorker
  include Sidekiq::Worker

  sidekiq_options queue: :telegram

  def perform
    TelegramAccount.where.not(telegram_id: nil).find_each do |account|
      new_data = RedmineBots::Telegram.bot.get_chat(chat_id: account.telegram_id)
      account.update(**new_data['result'].slice('username', 'first_name', 'last_name').symbolize_keys)
    end
  end
end
