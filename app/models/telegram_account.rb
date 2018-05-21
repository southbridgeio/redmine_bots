class TelegramAccount < ActiveRecord::Base
  belongs_to :user

  def name
    [first_name, last_name, username&.tap { |n| n.insert(0, '@') }].compact.join(' ')
  end
end
