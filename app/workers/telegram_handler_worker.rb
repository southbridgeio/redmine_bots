class TelegramHandlerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :telegram

  def perform(params)
    RedmineBots::Telegram.bot.handle_update(params)
  end
end
