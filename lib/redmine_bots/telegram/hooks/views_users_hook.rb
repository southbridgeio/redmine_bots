module RedmineBots
  module Telegram
    module Hooks
      class ViewsUsersHook < Redmine::Hook::ViewListener
        render_on :view_account_left_bottom, partial: "users/telegram_account", :user => @user
      end
    end
  end
end
