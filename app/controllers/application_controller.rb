class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :current_user

  private

  def current_user
    @current_user = session[:user_id] if session[:user_id]
  end

  def require_user
    if @current_user.blank?
      redirect_to root_url
    end
  end

  helper_method :current_user
end
