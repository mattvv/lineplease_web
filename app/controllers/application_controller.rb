class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :current_user

  private

  def current_user
    @user_id = session[:user_id] if session[:user_id]
  end

  helper_method :current_user
end
