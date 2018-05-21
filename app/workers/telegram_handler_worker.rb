class TelegramHandlerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :telegram

  TYPES = %w(inline_query
              chosen_inline_result
              callback_query
              edited_message
              message
              channel_post
              edited_channel_post)

  def perform(params)
    update = Telegram::Bot::Types::Update.new(params)
    message = TYPES.reduce(nil) { |m, t| m || update.public_send(t) }

    if message.present?
      RedmineBots::Telegram.update_manager.handle_message(message)
    else
      logger.fatal "Can't find message: #{params.to_json}"
    end
  end

  def logger
    @logger ||= Logger.new(Rails.root.join('log/redmine_bots',
                                           'telegram-handler.log'))
  end
end
