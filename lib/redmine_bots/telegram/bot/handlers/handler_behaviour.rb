module RedmineBots::Telegram::Bot::Handlers
  module HandlerBehaviour
    def match?(action)
      return false unless (action.private? && private?) || (action.group? && group?)

      if command?
        command, * = action.command

        return false unless command == name
      end

      true
    end

    def command?
      false
    end

    def name
      raise NotImplementedError
    end

    def private?
      false
    end

    def group?
      false
    end

    def description
      raise NotImplementedError
    end

    def allowed?(_user)
      false
    end
  end
end
