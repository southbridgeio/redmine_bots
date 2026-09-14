require 'faraday'
require 'json'

module RedmineBots
  module Yandex
    class Client
      TIMEOUT = 15
      OPEN_TIMEOUT = 5

      MAX_NAME_LENGTH = 200
      MAX_DESCRIPTION_LENGTH = 500
      MAX_TEXT_LENGTH = 6000
      MEMBERS_PAGE_SIZE = 1000

      class Error < RedmineBots::Yandex::Error
        attr_reader :status, :description, :code

        # `code` is the machine-readable error the API returns alongside the
        # human text — `user_not_found` and friends.
        def initialize(description, status = nil, code = nil)
          @description = description.presence || 'unknown error'
          @status = status
          @code = code
          super([status, @description].compact.join(': '))
        end

        def user_not_found?
          code == 'user_not_found'
        end
      end

      def initialize(token:, url: RedmineBots::Yandex::API_URL)
        raise Error.new('Yandex Messenger bot token is not configured') if token.blank?

        @token = token
        @url = url
      end

      def bot_info
        get('self/get')
      end

      def find_user(login)
        return if login.blank?

        get('users/getUserLink', login: login)['id']
      rescue Error => e
        raise unless e.user_not_found?

        nil
      end

      def update_bot(params)
        post('self/update/', params)
      end

      def create_chat(name:, description: '', members: [], admins: [], subscribers: [],
                      channel: false, public: false, avatar_url: nil)
        body = {
          name: truncate(name, MAX_NAME_LENGTH),
          description: truncate(description, MAX_DESCRIPTION_LENGTH)
        }
        body[:members] = users(members) if members.present?
        body[:admins] = users(admins) if admins.present?
        body[:subscribers] = users(subscribers) if subscribers.present?
        body[:avatar_url] = avatar_url if avatar_url.present?
        body[:channel] = true if channel
        body[:public] = true if public

        post('chats/create/', body)
      end

      def update_members(chat_id:, members: nil, admins: nil, subscribers: nil, remove: nil, notify: false)
        body = { chat_id: chat_id }
        body[:members] = users(members) if members.present?
        body[:admins] = users(admins) if admins.present?
        body[:subscribers] = users(subscribers) if subscribers.present?
        body[:remove] = users(remove) if remove.present?
        body[:send_members_updated_notifications] = true if notify

        post('chats/updateMembers/', body)
      end

      def chat_info(chat_id)
        get('chats/getInfo/', chat_id: chat_id)
      end

      # Returns the full member list, following the guid-based pagination.
      def chat_members(chat_id)
        members = []
        offset = nil

        loop do
          params = { chat_id: chat_id, limit: MEMBERS_PAGE_SIZE }
          params[:offset] = offset if offset
          page = Array(get('chats/getMembers/', params)['data'])
          members.concat(page)

          break if page.size < MEMBERS_PAGE_SIZE

          offset = page.last['guid']
          break if offset.blank?
        end

        members
      end

      def send_text(text:, chat_id: nil, login: nil, **params)
        raise Error.new('Either chat_id or login is required') if chat_id.blank? && login.blank?

        body = { text: truncate(text, MAX_TEXT_LENGTH) }
        body[:chat_id] = chat_id if chat_id.present?
        body[:login] = login if login.present?

        post('messages/sendText/', body.merge(params.compact))
      end

      private

      attr_reader :token, :url

      def users(list)
        Array(list).flatten.filter_map do |user|
          case user
          when Hash then user.symbolize_keys.slice(:login)
          else { login: user.to_s }
          end
        end.reject { |u| u[:login].blank? }.uniq
      end

      def truncate(value, limit)
        value.to_s.truncate(limit)
      end

      def get(path, params = {})
        request { connection.get(path, params) }
      end

      def post(path, body)
        request { connection.post(path) { |req| req.body = JSON.generate(body) } }
      end

      def request
        handle(yield)
      rescue Faraday::Error => e
        RedmineBots::Yandex.logger.error("Yandex API transport error: #{e.message}")
        raise Error.new(e.message)
      end

      def connection
        @connection ||= Faraday.new(url: url) do |conn|
          conn.headers['Authorization'] = "OAuth #{token}"
          conn.headers['Content-Type'] = 'application/json'
          conn.options.timeout = TIMEOUT
          conn.options.open_timeout = OPEN_TIMEOUT
          conn.adapter Faraday.default_adapter
        end
      end

      def handle(response)
        body = parse(response.body)

        unless response.success? && body['ok']
          raise Error.new(body['description'], response.status, body['code'])
        end

        body
      end

      def parse(raw)
        raw.blank? ? {} : JSON.parse(raw)
      rescue JSON::ParserError
        { 'description' => raw.to_s.truncate(200) }
      end
    end
  end
end
