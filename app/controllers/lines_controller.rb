class LinesController < ApplicationController
  before_filter :require_user

  def show
    @line = Line.get_line(params[:id]).first
    @script = Script.get_script(@line['scriptId']).first
    @lines = Script.lines(@line['scriptId'])
    @characters = []
    @lines.each do |line|
      character = line['character'].upcase
      @characters << character unless @characters.include?(character) or character.blank?
    end
  end

  def update
    character = params[:character].upcase
    if Line.update_line(params[:id], character, params[:line], params[:gender])
      current_line = Line.get_line(params[:id]).first
      lines = Script.lines(current_line['scriptId'])
      selected_character = character
      lines.each do |line|
        character = line['character'].upcase
        if selected_character == character
          Line.update_gender(line['objectId'], params[:gender])
        end
      end
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