module RedmineBots::Telegram::Tdlib
  class Command
    include TD::Types
    include Concurrent

    module Callable
      def call(*)
        return super unless auto_connect?
        connect.then { super }.flat
      end
    end

    private_class_method :new

    class << self
      def call(*args)
        Filelock(Rails.root.join('tmp', 'redmine_bots', 'tdlib_lock'), wait: 10) do
          begin
            client = RedmineBots::Telegram.tdlib_client
            new(client).call(*args).wait
          ensure
            client.dispose if defined?(client) && client
          end
        end
      end

      def inherited(klass)
        klass.prepend(Callable)
      end
    end


    def initialize(client)
      @client = client
    end

    def call(*)
      Concurrent::Promises.reject(NotImplementedError)
    end

    protected

    def auto_connect?
      true
    end

    attr_reader :client

    def connect
      client.connect
    end
  end
end
