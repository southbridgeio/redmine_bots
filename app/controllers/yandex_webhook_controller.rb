class YandexWebhookController < ActionController::Metal
  def update
    unless secret_valid?
      self.status = 403
      self.response_body = 'Forbidden'
      return
    end

    Array(params[:updates]).each do |update|
      YandexHandlerWorker.perform_async(update.as_json)
    end

    self.status = 200
    self.response_body = ''
  end

  private

  def secret_valid?
    ActiveSupport::SecurityUtils.secure_compare(params[:secret].to_s, RedmineBots::Yandex.webhook_secret)
  end
end
