require File.expand_path('../../test_helper', __FILE__)

class RedmineBots::Yandex::ConnectTest < ActiveSupport::TestCase
  let(:user) { User.find(1) }
  let(:handler) { RedmineBots::Yandex::Handlers::ConnectCommand.new }

  class FakeBot
    attr_reader :sent

    def initialize
      @sent = []
    end

    def reply(update, text, **params)
      @sent << [update, text, params]
    end
  end

  def update_for(text, login: 'petya@example.org', type: 'private')
    RedmineBots::Yandex::Update.new(
      'text' => text,
      'chat' => { 'type' => type },
      'from' => { 'login' => login, 'id' => 'guid-42', 'display_name' => 'Пётр', 'robot' => false }
    )
  end

  before do
    Setting.plugin_redmine_bots = Setting.plugin_redmine_bots.merge('yandex_bot_token' => 'AtTEST')
    YandexAccount.delete_all
  end

  it 'answers /connect and /start in a private chat only' do
    assert handler.match?(update_for('/connect'))
    assert handler.match?(update_for('/start'))
    refute handler.match?(update_for('/connect', type: 'group'))
    refute handler.match?(update_for('просто сообщение'))
  end

  it 'replies with a link carrying the login the update was signed with' do
    bot = FakeBot.new
    handler.call(update: update_for('/connect'), bot: bot)

    text = bot.sent.first[1]
    token = text[%r{/yandex/connect/(\S+)}, 1]
    payload = RedmineBots::Jwt.decode_token(token).first

    assert_equal 'petya@example.org', payload['yandex_login']
    assert_equal 'guid-42', payload['yandex_guid']
    assert_equal 'Пётр', payload['yandex_display_name']
  end

  it 'says so when the login is already linked' do
    YandexAccount.create!(user: user, login: 'petya@example.org', verified_at: Time.current)
    bot = FakeBot.new

    handler.call(update: update_for('/connect'), bot: bot)

    assert_includes bot.sent.first[1], user.name
  end

  it 'still offers a link when a hand-entered binding is not verified' do
    YandexAccount.create!(user: user, login: 'petya@example.org')
    bot = FakeBot.new

    handler.call(update: update_for('/connect'), bot: bot)

    assert_includes bot.sent.first[1], '/yandex/connect/'
  end

  it 'rejects a token signed by somebody else' do
    forged = JWT.encode({ yandex_login: 'boss@example.org', iss: Setting.host_name, exp: Time.now.to_i + 300 },
                        'not-our-secret')

    assert_raises(JWT::VerificationError) { RedmineBots::Jwt.decode_token(forged) }
  end

  it 'rejects an expired token' do
    expired = JWT.encode({ yandex_login: 'boss@example.org', iss: Setting.host_name, exp: Time.now.to_i - 1 },
                         Rails.application.config.secret_key_base)

    assert_raises(JWT::ExpiredSignature) { RedmineBots::Jwt.decode_token(expired) }
  end

  it 'ignores updates the bot itself produced' do
    delivered = []
    bot = RedmineBots::Yandex::Bot.new
    bot.register_handler(Class.new do
      define_method(:match?) { |_| true }
      define_method(:call) { |update:, bot:| delivered << update }
    end.new)

    bot.handle_update('text' => '/connect', 'chat' => { 'type' => 'private' },
                      'from' => { 'login' => 'bot@example.org', 'robot' => true })

    assert_empty delivered
  end

  it 'resolves the Redmine user behind an update' do
    YandexAccount.create!(user: user, login: 'petya@example.org')

    assert_equal user.id, update_for('привет', login: 'PETYA@example.org').user.id
    assert update_for('привет', login: 'nobody@example.org').user.anonymous?
  end
end
