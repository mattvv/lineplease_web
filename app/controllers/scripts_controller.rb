class ScriptsController < ApplicationController
  def index
    #todo: get this from current_user
    username = session[:username]
    #endtodo
    @scripts = Script.scripts(username)
  end

  def show
    @lines = Script.lines(params[:id])
  end
end