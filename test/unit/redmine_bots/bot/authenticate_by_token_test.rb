require File.expand_path('../../../../test_helper', __FILE__)

class RedmineBots::Telegram::Bot::AuthenticateByTokenTest < ActiveSupport::TestCase
  fixtures :telegram_accounts, :users

  let(:described_class) { RedmineBots::Telegram::Bot::AuthenticateByToken }

  context 'when user is anonymous' do
    it 'returns failure result' do
      result = described_class.new(users(:anonymous), 'token', context: 'account_connection').call

      expect(result.success?).must_equal false
      expect(result.value).must_equal "You're not logged in"
    end
  end

  context 'when token is invalid' do
    it 'returns failure result' do
      result = described_class.new(users(:logged), 'invalid_token', context: 'account_connection').call

      expect(result.success?).must_equal false
      expect(result.value).must_equal 'Token is invalid'
    end
  end

  context 'when telegram account found by user_id' do
    context 'when telegram ids do not match' do
      it 'returns failure result' do
        RedmineBots::Telegram::Jwt.stubs(:decode_token).returns([{ 'telegram_id' => 2 }, {}])

        result = described_class.new(users(:logged), 'token', context: 'account_connection').call

        expect(result.success?).must_equal false
        expect(result.value).must_equal "Wrong Telegram account"
      end
    end

    context 'when telegram ids match' do
      it 'updates attributes and returns successful result' do
        RedmineBots::Telegram::Jwt.stubs(:decode_token).returns([{ 'telegram_id' => 1 }, {}])

        result = described_class.new(users(:logged), 'token', context: 'account_connection').call

        account = TelegramAccount.find(1)

        expect(result.value).must_equal account
        expect(result.success?).must_equal true
      end
    end
  end

  context 'when telegram account not found by user_id' do
    context 'when user ids do not match' do
      it 'returns failure result' do
        RedmineBots::Telegram::Jwt.stubs(:decode_token).returns([{ 'telegram_id' => 1 }, {}])
        result = described_class.new(users(:user_3), 'token', context: 'account_connection').call

        expect(result.success?).must_equal false
        expect(result.value).must_equal "Wrong Telegram account"
      end
    end

    context 'when telegram account does not have user_id' do
      it 'updates attributes and returns successful result' do
        RedmineBots::Telegram::Jwt.stubs(:decode_token).returns([{ 'telegram_id' => 3 }, {}])
        result = described_class.new(users(:user_3), 'token', context: 'account_connection').call

        account = TelegramAccount.last

        expect(result.value).must_equal account
        expect(account.user_id).must_equal users(:user_3).id
        expect(result.success?).must_equal true
      end
    end
  end
end