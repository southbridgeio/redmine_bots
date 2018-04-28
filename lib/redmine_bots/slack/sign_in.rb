module RedmineBots::Slack
  class SignIn
    def self.call(*args)
      new.call(*args)
    end

    def initialize(client = RedmineBots::Slack.client)
      @client = client
    end

    def call(params)
      return false if current_user.anonymous?

      oauth = @client.oauth_access(client_id: client_id, client_secret: client_secret, code: params[:code])

      user_client = ::Slack::Web::Client.new(token: oauth.access_token)
      user_identity = user_client.users_identity

      slack_account = SlackAccount.find_or_initialize_by(user_id: current_user.id)

      attrs = { slack_id: user_identity.user.id, team_id: user_identity.team.id }

      if slack_account.new_record?
        slack_account.assign_attributes(attrs)
      else
        return false unless slack_account.slice(:slack_id, :team_id).symbolize_keys == attrs
      end

      slack_account.name = user_identity.user.name

      slack_account.save
    end

    private

    def current_user
      User.current
    end

    def client_id
      Setting.plugin_redmine_bots['slack_client_id']
    end

    def client_secret
      Setting.plugin_redmine_bots['slack_client_secret']
    end
  end
end
