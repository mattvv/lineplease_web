class Script
  def self.scripts(username)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      response = site["/classes/Script"].get({:params => {:order => "-createdAt", :where => {"username" => username }.to_json}})
      JSON.parse(response)["results"]
    rescue Exception => e
      false
    end
  end

  def self.get_script(script_id)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      response = site["/classes/Script"].get({:params => {:order => "createdAt", :where => {"objectId" => script_id }.to_json}})
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

  def self.add_script(name, username)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      response = site["/classes/Script"].post({"name"=>name, "username" => username}.to_json, :content_type => 'application/json', :accept => :json)
      !JSON.parse(response)["objectId"].blank?
    rescue Exception
      false
    end
  end

  def self.add_script_return(name, username)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      response = site["/classes/Script"].post({"name"=>name, "username" => username}.to_json, :content_type => 'application/json', :accept => :json)
      JSON.parse(response)["objectId"]
    rescue Exception
      false
    end
  end

  def self.add_line(script_id, character, line)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      response = site["/classes/Line"].post({"scriptId"=>script_id, "character" => character, "line" => line}.to_json, :content_type => 'application/json', :accept => :json)
      !JSON.parse(response)["objectId"].blank?
    rescue Exception
      false
    end
  end

  def self.remove_script(script_id)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      site["/classes/Script/#{script_id}"].delete
      true
    rescue Exception
      false
    end
  end

  def self.remove_line(line_id)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      site["/classes/Line/#{line_id}"].delete
      true
    rescue Exception
      false
    end
  end
end