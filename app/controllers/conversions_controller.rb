class ConversionsController < ApplicationController
  before_filter :require_user, :except => :enqueue

  def new

  end

  def create
    file = params[:file]
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY

    #upload the file to parse!
    begin
      file_response = site["/files/#{file.original_filename}"].post file.tempfile, :content_type => file.content_type#, :accept => :json)
      url = JSON.parse(file_response)["url"]
      response = site["/classes/Conversion"].post({"name"=>params[:script], "status" => "Queued...", "username" => @current_user.username, "percent" => 0, "file" => {"name" => url, "__type" => "File"}}.to_json, :content_type => 'application/json', :accept => :json)
      Resque.enqueue(Conversion, JSON.parse(response)["objectId"], @current_user.username)
      @conversion = Conversion.find(JSON.parse(response)["objectId"])
    rescue Exception => e
      flash[:message] = e.message
    end

    render :show
  end

  def enqueue
    Resque.enqueue(Conversion, params["conversionId"], params["username"])

    render :json => { 'status' => 'queued' }
  end

  def show
    @conversion = Conversion.find(params[:id])
  end


  def index
    @conversions = Conversion.where(:username => @current_user.username).order('-createdAt')
  end

  def status
    @conversion = Conversion.find(params[:id])
  end
end