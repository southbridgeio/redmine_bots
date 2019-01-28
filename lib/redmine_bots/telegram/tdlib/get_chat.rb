module RedmineBots::Telegram::Tdlib
  class GetChat < Command
    def call(id)
      client.get_chat(id)
    end
  end
end