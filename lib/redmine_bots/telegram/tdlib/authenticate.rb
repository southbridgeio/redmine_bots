module RedmineBots::Telegram::Tdlib
  class Authenticate < Command
    TIMEOUT = 10

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

        Timeout.timeout(TIMEOUT) do
          loop do
            case auth_state
            when 'authorizationStateWaitPhoneNumber'
              set_phone(params['phone_number'])
            when 'authorizationStateWaitCode'
              return unless params.key?('phone_code')
              check_code(params['phone_code'])
            when 'authorizationStateReady'
              return
            end
          end
        end
      rescue Timeout::Error
        msg = 'Failed to process request (timeout)'
        @logger.fatal(msg)
        raise AuthenticationError.new(msg)
      end
    end

    private

    def set_phone(phone)
      params = {
        '@type' => 'setAuthenticationPhoneNumber',
        'phone_number' => phone
      }
      @client.broadcast_and_receive(params).tap(&error_handler)
    end

    def check_code(code)
      params = {
        '@type' => 'checkAuthenticationCode',
        'code' => code
      }
      @client.broadcast_and_receive(params).tap(&error_handler)
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
