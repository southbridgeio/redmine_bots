require File.expand_path('../../test_helper', __FILE__)

class YandexAccountTest < ActiveSupport::TestCase
  let(:user) { User.find(1) }
  let(:other) { User.find(3) }

  before do
    Setting.plugin_redmine_bots = Setting.plugin_redmine_bots.merge('yandex_bot_token' => 'AtTEST')
    YandexAccount.delete_all
  end

  it 'trims the login and starts out unverified' do
    account = YandexAccount.create!(user: user, login: '  ivan@example.org  ')

    assert_equal 'ivan@example.org', account.login
    refute account.verified?
  end

  it 'looks a login up regardless of case and padding' do
    account = YandexAccount.create!(user: user, login: 'Ivan@Example.org')

    assert_equal account.id, YandexAccount.for_login('  ivan@example.ORG ').id
    assert_nil YandexAccount.for_login('')
    assert_nil YandexAccount.for_login(nil)
  end

  it 'refuses to bind one login to two users' do
    YandexAccount.create!(user: user, login: 'ivan@example.org')
    duplicate = YandexAccount.new(user: other, login: 'IVAN@example.org')

    refute duplicate.valid?
    assert duplicate.errors[:login].present?
  end

  it 'refuses a second account for the same user' do
    YandexAccount.create!(user: user, login: 'ivan@example.org')

    refute YandexAccount.new(user: user, login: 'other@example.org').valid?
  end

  it 'requires a login' do
    refute YandexAccount.new(user: user, login: '   ').valid?
  end
end

class RedmineBots::Patches::UserPatchTest < ActiveSupport::TestCase
  let(:user) { User.find(1) }

  before do
    Setting.plugin_redmine_bots = Setting.plugin_redmine_bots.merge('yandex_bot_token' => 'AtTEST')
    YandexAccount.delete_all
  end

  it 'is assignable through safe_attributes, so the profile form just works' do
    user.safe_attributes = { 'yandex_login' => ' ivan@example.org ' }
    user.save!

    assert_equal 'ivan@example.org', user.reload.yandex_login
    assert_equal 'ivan@example.org', RedmineBots::Yandex.login_for(user)
  end

  it 'drops the binding when the field is cleared' do
    user.yandex_login = 'ivan@example.org'
    user.save!

    user.yandex_login = ''
    user.save!

    assert_nil user.reload.yandex_account
    assert_nil RedmineBots::Yandex.login_for(user)
  end

  it 'never falls back to the Redmine e-mail' do
    assert_nil RedmineBots::Yandex.login_for(user)
  end

  it 'ignores locked users and non-users' do
    user.yandex_login = 'ivan@example.org'
    user.save!
    user.update_columns(status: User::STATUS_LOCKED)

    assert_nil RedmineBots::Yandex.login_for(user.reload)
    assert_nil RedmineBots::Yandex.login_for(Group.new)
    assert_nil RedmineBots::Yandex.login_for(nil)
  end
end
