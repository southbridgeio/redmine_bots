module RedmineBots::Telegram::Tdlib
  class FetchAllChats < Command
    def initialize(*)
      super

      @chat_list = ChatList::Main.new
      @limit = 100
      @chat_futures = []
    end

    def call
      fetch
    end

    private

    attr_reader :limit
    attr_accessor :chat_list, :offset_order, :offset_chat_id

    # there is a recursive call of fetch method, so we need to refactor this after fix tg work,
    # because it's hard to understand without stop points
    def fetch
      client.get_chats(chat_list: chat_list, limit: limit).then do |update|
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
