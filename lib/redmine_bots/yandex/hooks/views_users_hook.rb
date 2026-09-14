module RedmineBots
  module Yandex
    module Hooks
      class ViewsUsersHook < Redmine::Hook::ViewListener
        render_on :view_my_account, partial: 'users/yandex_account'
        render_on :view_users_form, partial: 'users/yandex_account'
      end
    end
  end
end
