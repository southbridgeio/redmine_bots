module RedmineBots::Slack
  class SignIn
    def self.call(*args)
      new.call(*args)
    end

    def initialize(client = RedmineBots::Slack.web_client)
      @client = client
    end

    def call(params)
      return false if current_user.anonymous?

      oauth = @client.oauth_access(client_id: '346628605728.347578530197', client_secret: 'a9370e717361d6ccff077f551e046768', code: params[:code])
      return false unless oauth.ok

      user_identity = @client.users_identity(token: oauth.access_token)
      return false unless user_identity.ok

      encrypted_token = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), Rails.application.config.secret_key_base, oauth.access_token)

      slack_account = SlackAccount.find_or_initialize_by(user_id: current_user.id)

      attrs = { token: encrypted_token, slack_id: user_identity.user.id, team_id: user_identity.team.id }

      if slack_account.new_record?
        slack_account.assign_attributes(attrs)
      else
        return false unless slack_account.slice(:token, :slack_id, :team_id).symbolize_keys == attrs
      end

      slack_account.name = user_identity.user.name

      slack_account.save
    end

    private

    def current_user
      User.current
    end
  end
end
