class YandexConnectController < ApplicationController
  before_action :require_login

  def show
    login, guid, display_name = token_payload

    return fail_with(:invalid_token) if login.blank?

    account = YandexAccount.for_login(login)

    if account && account.user_id != User.current.id
      return fail_with(:taken, user: account.user.name)
    end

    account ||= User.current.yandex_account || User.current.build_yandex_account

    account.assign_attributes(login: login, guid: guid, display_name: display_name, verified_at: Time.current)

    if account.save
      flash[:notice] = l_yandex(:connected, login: login)
    else
      flash[:error] = account.errors.full_messages.join(', ')
    end

    redirect_to my_account_path
  end

  private

  def token_payload
    payload = RedmineBots::Jwt.decode_token(params[:token]).first

    payload.values_at('yandex_login', 'yandex_guid', 'yandex_display_name')
  rescue ::JWT::DecodeError, ::JWT::ExpiredSignature
    []
  end

  def fail_with(key, **args)
    flash[:error] = l_yandex(key, **args)
    redirect_to my_account_path
  end

  def l_yandex(key, **args)
    I18n.t("redmine_bots.yandex.connect.#{key}", **args)
  end
end
