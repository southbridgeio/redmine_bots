require File.expand_path('../../../test_helper', __FILE__)

class TelegramAccountTest < ActiveSupport::TestCase
  def setup
    @telegram_account = TelegramAccount.new first_name: 'John', last_name: 'Smith'
  end

  def test_name_without_username
    assert_equal 'John Smith', @telegram_account.name
  end

  def test_name_with_username
    @telegram_account.username = 'john_smith'
    assert_equal 'John Smith @john_smith', @telegram_account.name
  end
end
