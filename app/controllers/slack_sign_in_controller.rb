class SlackSignInController < ApplicationController
  def index
  end

  def check
    if params[:error].blank? && RedmineBots::Slack::SignIn.(params)
      redirect_to my_page_path
    else
      render_403
    end
  end
end
