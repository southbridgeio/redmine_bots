module RedmineBots::Telegram::Tdlib
  class GetChat < Command
    def call(id)
      connect.then { client.get_chat(id) }.flat
    end
  end
end