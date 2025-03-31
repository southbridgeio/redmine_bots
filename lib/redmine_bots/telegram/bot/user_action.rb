# frozen_string_literal: true

class RedmineBots::Telegram::Bot
  class UserAction
    delegate :from, to: :message
    delegate :chat, to: :message
    delegate :id, to: :from, prefix: true, allow_nil: true
    delegate :id, to: :user, prefix: true
    delegate :id, to: :chat, prefix: true
    delegate :title, to: :chat, prefix: true
    delegate :message_id, to: :message

    attr_reader :message

    def self.from_payload(payload)
      new(Telegram::Bot::Types::Update.new(payload).current_message)
    end

    def initialize(message)
      @message = message
    end

    def telegram_account
      return @telegram_account if defined?(@telegram_account)

      @telegram_account =
        begin
          telegram_id = message.from.id
          TelegramAccount.find_by(telegram_id: telegram_id)
        end
    end

    def message?
      message.is_a?(::Telegram::Bot::Types::Message)
    end

    def callback_query?
      message.is_a?(::Telegram::Bot::Types::CallbackQuery)
    end

    def text
      if message? && !message.media_group_id
        if has_photo?
          message.caption.to_s
        else
          message.text.to_s
        end
      else
        ''
      end
    end

    def photo
      message.photo.max_by { |photo| photo.file_size }
    end

    def has_photo?
      message.photo.present? && !message.media_group_id
    end

    def command?
      message.is_a?(::Telegram::Bot::Types::Message) && message.text&.start_with?('/')
    end

    def command
      if command? && message.text.match(/^\/(\w+)/).present?
        return [message.text.match(/^\/(\w+)/)[1], message.text.match(/^\/\w+ (.+)$/).try(:[], 1)]
      end

      []
    end

    def private?
      message? && message.chat.type == 'private'
    end

    def group?
      !private?
    end

    def user
      telegram_account&.user || User.anonymous
    end
  end
end
