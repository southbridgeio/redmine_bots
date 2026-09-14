module RedmineBots
  module Jwt
    extend self

    TTL = 300

    def encode(payload)
      ::JWT.encode({ **payload, iss: issuer, exp: Time.now.to_i + TTL }, secret)
    end

    def decode_token(token)
      ::JWT.decode(token, secret, true, algorithm: 'HS256', iss: issuer, verify_iss: true)
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
