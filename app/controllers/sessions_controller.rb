class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.login(params[:username], params[:password])
    if user
      session[:user_id] = user.get_user_id
      redirect_to root_url, :notice => "Logged in!"
    else
      flash.now.alert = "Invalid user or password"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end