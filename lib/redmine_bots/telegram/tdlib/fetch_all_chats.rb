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
    attr_accessor :chat_list

    def fetch
      client.load_chats(chat_list: chat_list, limit: limit).then do |update|
        case update
        when TD::Types::Ok
          fetch.wait!
        else
          next Concurrent::Promises.fulfilled_future(nil)
        end
      end.flat.rescue do |error|
        if error.code != 404
          raise error
        end
      end
    end
  end
end
