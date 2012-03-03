class LinesController < ApplicationController
  before_filter :require_user

  def show
    @line = Line.get_line(params[:id]).first
    @script = Script.get_script(@line['scriptId']).first
  end

  def update
    if Line.update_line(params[:id], params[:character], params[:line])
      flash[:success] = "Updated Line"
    else
      flash[:error] = "Failed to Update Line"
    end
    redirect_to script_path(params[:script_id])
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