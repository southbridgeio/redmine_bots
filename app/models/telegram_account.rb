class TelegramAccount < ActiveRecord::Base
  belongs_to :user
end
