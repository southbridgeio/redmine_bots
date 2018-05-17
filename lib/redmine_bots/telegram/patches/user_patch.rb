module RedmineBots
  module Telegram
    module Patches
      module UserPatch
        def self.included(base)
          base.class_eval do
            unloadable

            has_one :telegram_account, dependent: :destroy, class_name: '::TelegramAccount'
          end
        end
      end
    end
  end
end
User.send(:include, RedmineBots::Telegram::Patches::UserPatch)
