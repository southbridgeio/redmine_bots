module RedmineBots::Telegram::Tdlib
  class Authenticate < Command
    TIMEOUT = 20

    class AuthenticationError < StandardError
    end

    def call(params)
      mutex = Mutex.new
      condition = ConditionVariable.new
      error = nil
      result = nil

      client.on(Update::AuthorizationState) do |update|
        promise = Promises.fulfilled_future(true)

        case update.authorization_state
        when AuthorizationState::WaitPhoneNumber
          promise = client.set_authentication_phone_number(phone_number: params[:phone_number], settings: nil)
        when AuthorizationState::WaitCode
          promise = client.check_authentication_code(code: params[:phone_code]) if params[:phone_code]
        when AuthorizationState::WaitPassword
          promise = client.check_authentication_password(password: params[:password]) if params[:password]
        when AuthorizationState::Ready
          promise = Promises.fulfilled_future(true)
        else
          next
        end

        mutex.synchronize do
          promise.then do |res|
            result = res
            condition.broadcast
          end.on_error do |err|
            error = err
            condition.broadcast
          end
        end
      end

      connect.then do
        Promises.future do
          mutex.synchronize do
            condition.wait(mutex, TIMEOUT)
            raise TD::Error.new(error) if error
            error = TD::Types::Error.new(code: 0, message: 'Unknown error. Please, see TDlib logs.') if result.nil?
            raise TD::Error.new(error) if error
            result
          end
        end
      end.flat
    end

    private

    def auto_connect?
      false
    end
  end
end
