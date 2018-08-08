module RedmineBots::Telegram::Tdlib
  class Authenticate < Command
    TIMEOUT = 20

    class AuthenticationError < StandardError
    end

    def initialize(client, logger)
      @logger = logger
      super(client)
    end

    def call(params)
      begin
        auth_state = nil

        @client.on('updateAuthorizationState') do |update|
          auth_state = update.dig('authorization_state', '@type')
        end

        loop do
          case auth_state
          when 'authorizationStateWaitPhoneNumber'
            set_phone(params['phone_number'])
          when 'authorizationStateWaitCode'
            return unless params.key?('phone_code')
            check_code(params['phone_code'])
          when 'authorizationStateReady'
            fetch_all_chats
            return
          end
        end
      rescue Timeout::Error
        msg = 'Failed to process request (timeout)'
        @logger.fatal(msg)
        raise AuthenticationError.new(msg)
      end
    end

    private

    def fetch_all_chats
      offset_order = 2**63 - 1
      offset_chat_id = 0
      limit = 100

      loop do
        chat_ids = @client.fetch('@type' => 'getChats', 'offset_order' => offset_order, 'offset_chat_id' => offset_chat_id, 'limit' => limit).tap(&error_handler)['chat_ids']
        break if chat_ids.empty?
        last_chat = @client.fetch('@type' => 'getChat', 'chat_id' => chat_ids.last).tap(&error_handler)
        offset_chat_id, offset_order = last_chat.values_at('id', 'order')
      end
    end

    def set_phone(phone)
      params = {
        '@type' => 'setAuthenticationPhoneNumber',
        'phone_number' => phone
      }
      @client.fetch(params).tap(&error_handler)
    end

    def check_code(code)
      params = {
        '@type' => 'checkAuthenticationCode',
        'code' => code
      }
      @client.fetch(params).tap(&error_handler)
    end

    def error_handler
      proc do |result|
        if result['@type'] == 'error'
          msg = "Failed to process request: #{result['code']} #{result['message']}"
          @logger.fatal(msg)
          raise AuthenticationError.new(msg)
        end
      end
    end
  end
end
