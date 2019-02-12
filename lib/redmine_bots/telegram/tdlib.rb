module RedmineBots::Telegram::Tdlib
  module_function

  def wrap(&block)
    Rails::VERSION::MAJOR < 5 ? yield : Rails.application.executor.wrap(&block)
  end

  def permit_concurrent_loads(&block)
    Rails::VERSION::MAJOR < 5 ? yield : ActiveSupport::Dependencies.interlock.permit_concurrent_loads(&block)
  end
end
