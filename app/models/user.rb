require "digest/sha1"

class User < ParseUser
  field :email

  def self.authenticate(username, password)
    user = super(username, password)
    session_id = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..10]
    Session.create(:session_id => session_id, :username => user.username, :user_id => user.id)
   end

  def self.authenticate_with_facebook(user_id, access_token, expires)
    user = super(user_id, access_token, expires)
    session_id = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..10]
    Session.create(:session_id => session_id, :username => user.username, :user_id => user.id)
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