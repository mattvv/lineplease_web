class ScriptsController < ApplicationController
  before_filter :require_user

  def create
    script = Script.new
    script.username = @current_user.username
    script.name = params[:name]
    if script.save
      flash[:success] = "Script #{params[:name]} Added"
    else
      flash[:error] = "Adding Script #{params[:name]} Failed: #{script.errors}"
    end
    redirect_to scripts_path
  end

  def index
    @scripts = Script.where(:username => @current_user.username).order('-createdAt')
  end

  def show
    @script = Script.find(params[:id])
    #todo: use associations here
    #@lines = @script.lines

    @lines = Line.where(:scriptId => @script.id).order(:position).all

    @characters = []
    @lines.each do |line|
      character = line.character.upcase
      @characters << character unless @characters.include?(character) or character.blank?
    end

    @line = Line.new
  end

  def destroy
    script = Script.find(params[:id])
    script.destroy
    flash[:success] = "Successfully Removed Script"
    #todo: delete lines assocaited with script
    redirect_to scripts_path
  end
end