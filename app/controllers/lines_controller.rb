class LinesController < ApplicationController
  before_filter :require_user

  def create
    unless params[:line][:id].blank?
      update
      return
    end
    line = Line.new(params[:line])
    line.scriptId = params[:script_id]
    if line.save
      flash[:success] = "Added Line!"
    else
      flash[:error] = "Failed to Add Line: #{line.errors}"
    end

    #todo: Ajax return if call is js
    redirect_to script_path(line.scriptId)
  end

  def show
    @line = Line.find(params[:id])
    @script = Script.find(@line.scriptId)
    @lines = Line.where(:scriptId => @line.scriptId).all
    @characters = []
    @lines.each do |line|
      character = line.character.upcase
      @characters << character unless @characters.include?(character) or character.blank?
    end
  end

  def update
    current_line = Line.new(params[:line])
    current_line.character.upcase!
    current_line.save

    if current_line.valid?
      #todo: move this to an after save on the object.
      lines = Line.where(:scriptId => current_line.scriptId).all
      lines.each do |line|
        character = line.character.upcase
        if current_line.character == character
          line.gender = params[:gender]
          line.save
        end
      end
      flash[:success] = "Updated Line"
    else
      flash[:error] = "Failed to Update Line #{current_line.errors.first}"
    end
    redirect_to script_path(current_line.scriptId)
  end

  def destroy
    line = Line.find(params[:id])
    script_id = line.scriptId
    line.destroy
    flash[:success] = "Line Removed!"
    redirect_to script_path(script_id)
  end

  def update_position
    @line = Line.get_line(params[:line_id]).first
    @lines = Script.lines(@line['scriptId'])
    position = params[:position].to_i
    line_above = @lines[position]
    line_below = @lines[position+1]
    time_between = (Time.parse(line_below['createdAt']) - Time.parse(line_above['createdAt'])) / 2
    new_time = Time.parse(line_above['createdAt']) + time_between
    Line.update_time(params[:line_id], new_time)
    render :nothing => true
  end
end