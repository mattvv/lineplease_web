class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :current_user, :parse_facebook_cookies

  private

  def parse_facebook_cookies
   @facebook_cookies ||= Koala::Facebook::OAuth.new.get_user_info_from_cookie(cookies)
   unless @facebook_cookies.nil? or !!@current_user
    unless @facebook_cookies['user_id'].blank? or @facebook_cookies['access_token'].blank? or @facebook_cookies['expires'].blank?
      us = User.authenticate_with_facebook(@facebook_cookies['user_id'], @facebook_cookies['access_token'], @facebook_cookies['expires'])
      session[:user_id] = us if us
    end
   end
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
