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
        tries ||= 3
        Filelock Rails.root.join('tmp', 'redmine_bots', 'tdlib_lock'), wait: 10 do
          super
        end
      rescue Timeout::Error
        sleep 2
        retry unless (tries -= 1).zero?
      ensure
        @client.close
      end
    end
  end
end
