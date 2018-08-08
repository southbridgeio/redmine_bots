module RedmineBots
  class Result
    attr_reader :value

    def initialize(success, value)
      @success, @value = success, value
    end

    def success?
      @success
    end

    def failure?
      !success?
    end
  end
end
