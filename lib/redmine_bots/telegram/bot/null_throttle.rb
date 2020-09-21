class RedmineBots::Telegram::Bot
  class NullThrottle
    def apply(*)
      yield
    end
  end
end
