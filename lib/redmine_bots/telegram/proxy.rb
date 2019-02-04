module RedmineBots::Telegram
  Proxy = Struct.new(:host, :port, :user, :password, keyword_init: true) do
    def self.parse(proxy)
      if proxy.include?('@')
        auth, proxy = proxy.split('@',2)
        user, password = auth.split(':')
      else
        user = nil
        password = nil
      end

      host, port = proxy.split(':',2)
      port = port.to_i if port

      return new(
        host: host,
        port: port,
        user: user,
        password: password
      )
    end
  end
end
