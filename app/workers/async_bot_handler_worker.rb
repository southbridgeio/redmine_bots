class AsyncBotHandlerWorker
  include Sidekiq::Worker

  def perform(method, args)
    RedmineBots::Telegram.set_locale

    RedmineBots::Telegram.bot.send(method, **args.symbolize_keys)
  end
end
