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
        Filelock Rails.root.join('tmp', 'redmine_bots', 'tdlib_lock'), wait: 10 do
          client = RedmineBots::Telegram.tdlib_client
          new(client).call(*args).wait
        ensure
          client.dispose
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

      settings = Setting.find_by_name(:plugin_redmine_bots).value

      if settings['tdlib_use_proxy']
        proxies = settings['telegram_proxies'].split("\n").map(RedmineBots::Telegram::Proxy.method(:parse))

        promises = proxies.map do |proxy|
          type = TD::Types::ProxyType::Socks5.new(username: proxy.user, password: proxy.password)
          client.add_proxy(proxy.host, proxy.port, type, false).then do |td_proxy|
            client.ping_proxy(td_proxy.id).then { client.enable_proxy(td_proxy.id) }.flat
          end.flat
        end

        Concurrent::Promises.any(*promises).then { client.ready }.flat
      else
        client.ready
      end
    end

    def before_connection; end
  end
end
