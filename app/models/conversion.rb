class Conversion < ActiveRecord::Base
  def self.upload_conversion(file, script)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      response = site["/files/#{file.original_filename}"].post file, :content_type => file.content_type#, :accept => :json)
      response
    rescue Exception => e
      e.message
      false
    end
  end

end