class RedmineBots::Telegram::Bot
  class AsyncHandler
    def initialize(_bot)
      ;
    end

    def send_message(*args)
      AsyncBotHandlerWorker.perform_async('send_message', *args)
    end
  end
end
