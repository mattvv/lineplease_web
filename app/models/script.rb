class Script
  def self.scripts(username)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      response = site["/classes/Script"].get({:params => {:where => {"username" => username }.to_json}})
      JSON.parse(response)["results"]
    rescue Exception => e
      false
    end
  end

  def self.lines(script_id)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      response = site["/classes/Line"].get({:params => {:order => "createdAt", :where => {"scriptId" => script_id }.to_json}})
      JSON.parse(response)["results"]
    rescue Exception => e
      false
    end
  end
end