class TelegramLoginController < AccountController
  def index
  end

  def check_auth
    user = User.find_by_id(session[:otp_user_id]) || User.current
    auth = RedmineBots::Telegram::Bot::Authenticate.(user, login_params, context: context)

    handle_auth_result(auth, user)
  end

  private

  def context
    session[:otp_user_id] ? '2fa_connection' : 'account_connection'
  end

  def handle_auth_result(auth, user)
    if auth.success?
      if user != User.current
        user.update!(two_fa: 'telegram')
        successful_authentication(user)
      else
        redirect_to my_page_path, notice: t('redmine_bots.telegram.bot.login.success')
      end
    else
      render_403(message: auth.value)
    end
  end

  def login_params
    params.permit(:id, :first_name, :last_name, :username, :photo_url, :auth_date, :hash)
  end
end
