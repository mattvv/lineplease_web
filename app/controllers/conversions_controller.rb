class ConversionsController < ApplicationController
  before_filter :require_user

  def new

  end

  def create
    @file = params[:file].content_type
    puts "content type: #{@file}"
  end


  def index
  end
end