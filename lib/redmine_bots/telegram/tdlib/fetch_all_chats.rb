module RedmineBots::Telegram::Tdlib
  class FetchAllChats < Command
    def initialize(*)
      super

      @offset_order = 2**63 - 1
      @offset_chat_id = 0
      @limit = 100
      @chat_futures = []
    end

    def call
      connect.then { fetch_chats }.flat
    end

    private

    attr_reader :limit
    attr_accessor :offset_order, :offset_chat_id

    def fetch_chats
      client.get_chats(offset_chat_id, limit, offset_order: offset_order).then do |update|
        chat_ids = update.chat_ids
        next Concurrent::Promises.fulfilled_future(nil) if chat_ids.empty?

        client.get_chat(chat_ids.last).then do |chat|
          self.offset_chat_id, self.offset_order = chat.id, chat.order
          fetch_chats.wait!
        end.flat
      end.flat
    end
  end
end
