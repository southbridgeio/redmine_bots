module RedmineRedmineBots::Telegram
  module Hooks
    class ViewsUsersHook < Redmine::Hook::ViewListener
      render_on :view_account_left_bottom, :partial => "telegram_common/users/telegram_account", :user => @user
    end
  end
end
