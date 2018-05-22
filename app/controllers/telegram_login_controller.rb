class TelegramLoginController < AccountController
  include RedmineBots::Jwt

  def index
  end

  def check_auth
    user = User.find_by_id(session[:otp_user_id]) || User.current

    auth = RedmineBots::Telegram::Bot::Authenticate.(user, login_params)

    if auth.success?
      if session[:otp_user_id]
        user.update_column(:two_fa_id, AuthSource.find_by_name('Telegram').id)
        successful_authentication(user)
      else
        redirect_to my_page_path, notice: t('redmine_bots.telegram.bot.login.success')
      end
    else
      render_403(message: auth.value)
    end
  end

  def check_jwt
    user = User.find_by_id(session[:otp_user_id]) || User.current


    if authenticate(user, params[:token])
      if session[:otp_user_id]
        user.update_column(:two_fa_id, AuthSource.find_by_name('Telegram').id)
        successful_authentication(user)
      else
        redirect_to my_page_path, notice: t('redmine_bots.telegram.bot.login.success')
      end
    else
      render_403
    end

  rescue JWT::DecodeError
    render_401
  rescue JWT::ExpiredSignature, JWT::InvalidIssuerError, JWT::InvalidIatError
    render_403
  end

  private

  def login_params
    params.permit(:id, :first_name, :last_name, :username, :photo_url, :auth_date, :hash)
  end
end
