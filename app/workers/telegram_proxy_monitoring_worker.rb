class TelegramProxyMonitoringWorker
  include Sidekiq::Worker

  def perform
    TelegramProxy.find_each(&:check!)
  end
end
