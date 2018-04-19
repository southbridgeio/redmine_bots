module RedmineBots::Slack::Commands
  class Connect < Base
    private_only
    responds_to :connect, :start

    def call
      reply(text: current_user.logged? ? 'Already connected' : sign_in_link)
    end

    private

    def sign_in_link
      "Please, follow link: #{Setting.protocol}://#{Setting.host_name}/slack/sign_in"
    end
  end
end
