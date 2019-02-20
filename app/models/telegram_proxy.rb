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
    return '' unless host.present?
    "#{protocol}://#{user ? "#{[user, password.to_s].join(':')}@" : ''}#{[host, port].join(':')}"
  end

  def check!
    status =
        begin
          connection.get('/').status
        rescue Faraday::ClientError
          nil
        end
    update(alive: status == 200)
  end

  private

  def connection
    Faraday.new('https://telegram.org') do |conn|
      conn.adapter(:patron) do |adapter|
        adapter.proxy = url
        adapter.force_ipv4 = true
      end
    end
  end
end
