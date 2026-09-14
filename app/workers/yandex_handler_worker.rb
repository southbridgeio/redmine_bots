class YandexHandlerWorker
  include Sidekiq::Worker

  def perform(payload)
    RedmineBots::Yandex.bot.handle_update(payload)
  end
end
