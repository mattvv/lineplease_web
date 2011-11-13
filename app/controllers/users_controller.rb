class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    if User.sign_up(params[:username], params[:password], params[:email])
      us = User.login(params[:username], params[:password])
      if us
        session[:user_id] = us
        #TODO: Create a session ID in models
        redirect_to scripts_url, :notice => "Signed up"
      else
        flash.now.alert = "Invalid user or password"
        render "new"
      end
    else
      render "new"
    end
  end
end
