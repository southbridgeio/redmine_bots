class TelegramWebhookController < ActionController::Metal
  def update
    TelegramHandlerWorker.perform_async(params)
    
    self.status = 200
    self.response_body = ''
  end
end
