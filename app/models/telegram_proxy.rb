class TelegramProxy < ActiveRecord::Base
  enum protocol: %i[http socks5]

  validates_presence_of :host, :port, :protocol

  scope :alive, -> { where(alive: true) }

  def assign_attributes(new_attributes)
    attributes = new_attributes.stringify_keys
    url = attributes.delete('url')
    return super unless url

    uri = URI(url)

    protocol = uri.scheme.in?(self.class.protocols.keys) ? uri.scheme : nil

    super(attributes.merge(user: uri.user, password: uri.password, host: uri.host, port: uri.port, protocol: protocol))
  end

  def url
    "#{protocol}://#{user ? "#{[user, password.to_s].join(':')}@" : ''}#{host}:#{port}"
  end

  def check!
    response = connection.get('/')
    update(alive: response.status == 200)
  end

  private

  def connection
    Faraday.new('https://telegram.org') do |conn|
      conn.adapter(:patron) { |adapter| adapter.proxy = url }
    end
  end
end
