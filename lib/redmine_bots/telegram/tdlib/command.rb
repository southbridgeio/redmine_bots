module RedmineBots::Telegram::Tdlib
  class Command
    def self.inherited(subclass)
      subclass.prepend Callable
    end

    def initialize(client)
      @client = client
    end

    module Callable
      def call(*)
        begin
          tries ||= 3
          super
        rescue Timeout::Error
          sleep 2
          retry unless (tries -= 1).zero?
        ensure
          @client.close
        end
      end
    end
  end
end
