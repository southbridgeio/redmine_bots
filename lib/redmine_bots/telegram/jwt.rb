module RedmineBots::Telegram
  module Jwt
    extend self

    def encode(payload)
      JWT.encode(**payload, iss: issuer)
    end

    def decode_token(token)
      JWT.decode(token, secret, true, algorithm: 'HS256', iss: issuer, verify_iss: true)
    end

    def authenticate(user, token)
      payload, header = decode_token(token)
      payload['user_id'] == user.id && user.logged?
    end

    private

    def secret
      Rails.application.config.secret_key_base
    end

    def issuer
      Setting.host_name
    end
  end
end
