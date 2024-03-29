class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      us = User.authenticate(@user.username, @user.password)
      if !!us
        session[:user_id] = us
        redirect_to scripts_url, :notice => "Signed up"
      else
        flash[:error] = "Username is already taken"
        render "new"
      end
    else
      flash[:error] = "Error creating User"
      render "new"
    end
  end

  def request_reset_password
  end

  def reset_password
    email = params[:email]
    unless User.reset_password(email)
      flash[:error] = "Failed to Reset Password"
      render "request_reset_password"
    end
  end
end
