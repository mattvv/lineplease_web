class ConversionsController < ApplicationController
  before_filter :require_user

  def new

  end

  def create
    file = params[:file]
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY

    #upload the file to parse!
    begin
      file_response = site["/files/#{file.original_filename}"].post file.tempfile, :content_type => file.content_type#, :accept => :json)
      url = JSON.parse(file_response)["url"]
      response = site["/classes/Conversion"].post({"name"=>params[:script], "file" => {"name" => url, "__type" => "File"}}.to_json, :content_type => 'application/json', :accept => :json)
      Resque.enqueue(Conversion, JSON.parse(response)["objectId"], @current_user.username)
    rescue Exception => e
      e.message
      false
    end
  end


  def index
  end
end