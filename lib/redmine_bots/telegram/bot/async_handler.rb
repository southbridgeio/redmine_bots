class RedmineBots::Telegram::Bot
  class AsyncHandler
    def initialize(_bot)
      ;
    end

    def send_message(*args)
      AsyncBotHandlerWorker.perform_async('send_message', *args)
    end

    def promote_chat_member(*args)
      AsyncBotHandlerWorker.perform_async('promote_chat_member', *args)
    end
  end
end
