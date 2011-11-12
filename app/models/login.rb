class Login < ActiveResource::Base
  self.site = "https://api.parse.com/1"
  self.user = APPLICATION_ID
  self.password = MASTER_KEY
end