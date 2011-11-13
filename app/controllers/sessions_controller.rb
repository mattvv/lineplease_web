class SessionsController < ApplicationController
  def new
  end

  def create
    us = User.login(params[:username], params[:password])
    if us
      session[:user_id] = us
      #TODO: Create a session ID in models
      redirect_to scripts_url, :notice => "Logged in!"
    else
      flash.now.alert = "Invalid user or password"
      render "new"
    end
  end

  def destroy
    #TODO: Delete Session from models
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end