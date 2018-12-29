module RedmineBots::Telegram::Tdlib
  class Command
    include TD::Types
    include Concurrent

    private_class_method :new

    class << self
      def call(*args)
        Filelock Rails.root.join('tmp', 'redmine_bots', 'tdlib_lock'), wait: 10 do
          client = RedmineBots::Telegram.tdlib_client
          new(client).call(*args).wait
        ensure
          client.dispose
        end
      end
    end


    def initialize(client)
      @client = client
    end

    def call(*)
      Concurrent::Promise.reject(NotImplementedError)
    end

    protected

    attr_reader :client
  end
end
