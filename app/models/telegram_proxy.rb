class TelegramProxy < ActiveRecord::Base
  enum protocol: %i[http socks5]

  validates_presence_of :host, :port, :protocol, :alive

  scope :alive, -> { where(alive: true) }

  def assign_attributes(new_attributes)
    attributes = new_attributes.stringify_keys
    proxy = attributes.delete('proxy_string')

    return super unless proxy

    if proxy.include?('@')
      auth, proxy = proxy.split('@',2)
      user, password = auth.split(':')
    else
      user = nil
      password = nil
    end

    host, port = proxy.split(':',2)
    port = port.to_i if port

    super(attributes.merge(user: user, password: password, host: host, port: port))
  end
end
