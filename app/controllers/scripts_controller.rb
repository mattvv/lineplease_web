class ScriptsController < ApplicationController
  before_filter :require_user

  def create
    if params[:id]
      Script.add_line(params[:id], params[:character], params[:line])
      redirect_to script_path(params[:id])
    else
      Script.add_script(params[:name], @current_user.username)
      redirect_to scripts_path
    end
  end

  def index
    @scripts = Script.scripts(@current_user.username)
  end

  def show
    @script = params[:id]
    @name = params[:name]
    @lines = Script.lines(@script)
  end

  def destroy
    unless params[:line_id].blank?
      Script.remove_line(params[:line_id])
      redirect_to script_path(params[:id])
    else
      Script.remove_script(params[:id])
      redirect_to scripts_path
    end
  end
end