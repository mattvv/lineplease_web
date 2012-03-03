class ScriptsController < ApplicationController
  before_filter :require_user

  def create
    if params[:id]
      if Script.add_line(params[:id], params[:character], params[:line])
        flash[:success] = "Added Line!"
      else
        flash[:error] = "Failed to Add Line"
      end
      redirect_to script_path(params[:id])
    else
      if Script.add_script(params[:name], @current_user.username)
        flash[:success] = "Script #{params[:name]} Added"
      else
        flash[:error] = "Adding Script #{params[:name]} Failed"
      end
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

    @characters = []
    @lines.each do |line|
      character = line['character'].upcase
      @characters << character unless @characters.include?(character) or character.blank?
    end
  end

  def destroy
    unless params[:line_id].blank?
      if Script.remove_line(params[:line_id])
        flash[:success] = "Successfully Removed Line"
      else
        flash[:error] = "Failed to Remove Line"
      end
      redirect_to script_path(params[:id])
    else
      if Script.remove_script(params[:id])
        flash[:success] = "Successfully Removed Script"
      else
        flash[:error] = "Failed to Remove Script"
      end
      redirect_to scripts_path
    end
  end
end