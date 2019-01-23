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
          promise = client.set_authentication_phone_number(params[:phone_number])
        when AuthorizationState::WaitCode
          promise = client.check_authentication_code(params[:phone_code]) if params[:phone_code]
        when AuthorizationState::Ready
          promise = fetch_all_chats
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
            raise TD::ErrorProxy.new(error) if error
            error = TD::Types::Error.new(code: 0, message: 'Unknown error. Please, see TDlib logs.') if result.nil?
            raise TD::ErrorProxy.new(error) if error
            result
          end
        end
      end.flat
    end

    private

    def fetch_all_chats
      offset_order = 2**63 - 1
      offset_chat_id = 0
      limit = 100

      fetch_chats = proc do
        client.get_chats(offset_chat_id, limit, offset_order).flat.then do |update|
          chat_ids = update.chat_ids
          unless chat_ids.empty?
            client.get_chat(chat_ids.last).then do |chat|
              offset_chat_id, offset_order = chat.id, chat.order
              fetch_chats.call
            end
          end
        end
      end
    end
  end
end
