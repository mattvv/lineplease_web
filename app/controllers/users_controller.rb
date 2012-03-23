class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.save
    if @user.valid?
      us = User.login(@user.username, @user.password)
      if us
        session[:user_id] = us
        redirect_to scripts_url, :notice => "Signed up"
      else
        flash[:error] = "Invalid user or password"
        render "new"
      end
    else
      flash[:error] = "Error creating User"
      render "new"
    end
  end
end
