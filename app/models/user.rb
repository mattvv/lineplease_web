require "digest/sha1"

class User < ParseUser
  field :email

  validates :email,
            :presence => true,
            :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }

  def self.authenticate(username, password)
    user = super(username, password)
    return false unless !!user
    session_id = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..10]
    Session.create(:session_id => session_id, :username => user.username, :user_id => user.id)
   end

  def self.authenticate_with_facebook(user_id, access_token, expires)
    user = super(user_id, access_token, expires)
    return false unless !!user
    session_id = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..10]
    Session.create(:session_id => session_id, :username => user.username, :user_id => user.id)
  end
end