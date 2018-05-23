class RedmineBots::Telegram::UpdateManager
  COMMON_COMMANDS = %w[help start connect token]

  def initialize
    @handlers = []
  end

  def add_handler(handler)
    @handlers << handler
  end

  def handle_message(message)
    command_name = message.text.to_s.scan(%r{^/(\w+)}).flatten.first
    handle_common_command(message) if COMMON_COMMANDS.include?(command_name)
    @handlers.each { |handler| handler.call(message) }
  end

  private

  def handle_common_command(message)
    RedmineBots::Telegram::Bot.new(RedmineBots::Telegram.bot_token, message).call
  end
end
