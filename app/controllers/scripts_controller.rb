class ScriptsController < ApplicationController
  before_filter :require_user

  def index
    @scripts = Script.scripts(@current_user.username)
  end

  def show
    @lines = Script.lines(params[:id])
  end
end