class TelegramWebhookController < ActionController::Metal
  def update
    unless secret_valid?
      self.status = 403
      self.response_body = 'Forbidden'
      return
    end

    TelegramHandlerWorker.perform_async(params)

    self.status = 200
    self.response_body = ''
  end

  private

  def secret_valid?
    params[:secret] == RedmineBots::Telegram.webhook_secret
  end
end
