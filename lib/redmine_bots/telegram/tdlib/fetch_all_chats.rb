module RedmineBots::Telegram::Tdlib
  class FetchAllChats < Command
    def initialize(*)
      super

      @chat_list = ChatList::Main.new
      @offset_order = 2**63 - 1
      @offset_chat_id = 0
      @limit = 100
      @chat_futures = []
    end

    def call
      fetch
    end

    private

    attr_reader :limit
    attr_accessor :chat_list, :offset_order, :offset_chat_id

    def fetch
      client.get_chats(chat_list: chat_list, offset_order: offset_order, offset_chat_id: offset_chat_id, limit: limit).then do |update|
        chat_ids = update.chat_ids
        next Concurrent::Promises.fulfilled_future(nil) if chat_ids.empty?

        client.get_chat(chat_id: chat_ids.last).then do |chat|
          self.offset_chat_id, self.offset_order = chat.id, chat.positions.find { |p| p.list.is_a?(ChatList::Main) }.order
          fetch.wait!
        end.flat
      end.flat
    end
  end
end
