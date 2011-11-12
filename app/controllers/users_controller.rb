class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    if User.sign_up(params[:username], params[:password], params[:email])
      #TODO: Login&Redirect
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new"
    end
  end
end
