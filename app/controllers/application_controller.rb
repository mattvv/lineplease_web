class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :current_user, :parse_facebook_cookies

  private

  def parse_facebook_cookies
   @facebook_cookies ||= Koala::Facebook::OAuth.new.get_user_info_from_cookie(cookies)
  end

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
