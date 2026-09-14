module RedmineBots
  module Patches
    module UserPatch
      def self.prepended(base)
        base.class_eval do
          has_one :yandex_account, dependent: :destroy, autosave: true

          safe_attributes 'yandex_login'
        end
      end

      def yandex_login
        yandex_account&.login
      end

      # Clearing the field removes the binding rather than storing a blank login.
      def yandex_login=(value)
        value = value.to_s.strip

        if value.blank?
          yandex_account&.mark_for_destruction
        elsif yandex_account
          yandex_account.login = value
        else
          build_yandex_account(login: value)
        end
      end
    end
  end
end
