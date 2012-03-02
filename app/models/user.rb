require "digest/sha1"
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
      #user = User.new(:username =>username, :user_id => )
      session_id = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..10]
      Session.create(:session_id => session_id, :username => username, :user_id => JSON.parse(response)["objectId"])
    rescue Exception => e
      false
    end
  end

  def self.login_with_facebook(user_id, access_token, expires)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      response = site["/users"].post(
            { "authData" =>
                  { "facebook" =>
                        {
                            "id" => user_id,
                            "access_token" => access_token,
                            "expiration_date" => Time.now + expires.to_i
                        }
                  }
            }.to_json,
           :content_type => 'application/json', :accept => :json)
      #user = User.new(:username =>username, :user_id => )
      session_id = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..10]
      Session.create(:session_id => session_id, :username => JSON.parse(response)["username"], :user_id => JSON.parse(response)["objectId"])
    rescue Exception => e
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