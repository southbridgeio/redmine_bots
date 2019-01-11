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

    def connect
      client.connect

      if settings['tdlib_use_proxy']
        proxy = TD::Types::ProxyType::Socks5.new(username: settings['tdlib_proxy_user'],
                                                 password: settings['tdlib_proxy_password'])
        client.add_proxy(settings['tdlib_proxy_server'],
                         settings['tdlib_proxy_port'],
                         proxy,
                         true).flat_map { client.ready }
      else
        client.ready
      end
    end

    def before_connection; end
  end
end
