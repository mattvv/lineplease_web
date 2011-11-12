class User
  attr_accessor :user_id, :username

  def initialize(options={})
      self.user_id = options[:user_id]
      self.username = options[:username]
  end

  def self.sign_up(username, password, email)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      response = site["/users"].post({"username"=>username, "password" => password, "email" => email}.to_json, :content_type => 'application/json', :accept => :json)
      !JSON.parse(response)["objectId"].blank?
    rescue Exception
      false
    end
  end

  #returns a user with login
  def self.login(username, password)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      response = site["/login"].get({:params => {"username"=>username, "password" => password}})
      user = User.new(:username =>username, :password => JSON.parse(response)["objectId"])
    rescue Exception
      false
    end
  end

  def get_user_id
    self.user_id
  end

  def get_username
    self.username
  end
end