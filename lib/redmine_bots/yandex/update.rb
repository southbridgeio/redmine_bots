module RedmineBots
  module Yandex
    class Update
      def initialize(payload)
        @payload = (payload || {}).with_indifferent_access
      end

      attr_reader :payload

      def from_login
        payload.dig(:from, :login).presence
      end

      def from_guid
        payload.dig(:from, :id).presence
      end

      def display_name
        payload.dig(:from, :display_name).presence
      end

      def from_bot?
        payload.dig(:from, :robot).present?
      end

      def chat_id
        payload.dig(:chat, :id).presence
      end

      def chat_type
        payload.dig(:chat, :type)
      end

      def private?
        chat_type == 'private'
      end

      def group?
        chat_type == 'group'
      end

      def text
        payload[:text].to_s
      end

      def command
        text[%r{\A/(\w+)}, 1]
      end

      def command?
        command.present?
      end

      def message_id
        payload[:message_id]
      end

      def sent_at
        Time.at(payload[:timestamp].to_i) if payload[:timestamp]
      end

      def user
        @user ||= YandexAccount.for_login(from_login)&.user || ::User.anonymous
      end
    end
  end
end
