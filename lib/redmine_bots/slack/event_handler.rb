module RedmineBots::Slack
  class EventHandler
    def self.event
      raise NotImplementedError
    end

    def self.to_proc
      ->(client, data) { new(client, data).call }
    end

    def initialize(client, data)
      @client = client
      @data = data
    end

    def call
      raise NotImplementedError
    end

    protected

    attr_reader :client, :data

    def reply(**attrs)
      client.say(attrs.merge(channel: data.channel))
    end
  end
end
