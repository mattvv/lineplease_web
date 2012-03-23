class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:username], params[:password])
    if user
      session[:user_id] = user
      redirect_to scripts_url, :notice => "Logged in!"
    else
      flash.now.notice = "Invalid username or password"
      render "new"
    end
  end

  def destroy
    us = Session.find(@current_user)
    us.destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end