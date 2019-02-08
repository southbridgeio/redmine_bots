class TelegramProxiesController < ApplicationController
  before_action :check_admin

  def index
    @proxies = TelegramProxy.all

    respond_to do |format|
      format.js
    end
  end

  def new
    @proxy = TelegramProxy.new

    respond_to do |format|
      format.js
    end
  end

  def update
    params[:proxies].each do |params|
      id, proxy_params = params[:id], filter_params(params)
      proxy = id.present? ? TelegramProxy.find(id) : TelegramProxy.new
      proxy.assign_attributes(proxy_params)
      proxy.save
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @proxy = TelegramProxy.find(params[:id])
    @proxy.destroy

    respond_to do |format|
      format.js
    end
  end

  private

  def check_admin
    raise Unauthorized unless User.current.admin?
  end

  def filter_params(params)
    params.permit(:url)
  end
end
