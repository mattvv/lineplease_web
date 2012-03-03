class Line
  def self.get_line(line_id)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      response = site["/classes/Line"].get({:params => {:order => "createdAt", :where => {"objectId" => line_id }.to_json}})
      JSON.parse(response)["results"]
    rescue Exception => e
      false
    end
  end

  def self.update_line(line_id, character, line)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    begin
      response = site["/classes/Line/#{line_id}"].put({"character"=>character, "line" => line}.to_json, :content_type => 'application/json', :accept => :json)
      !JSON.parse(response)["updatedAt"].blank?
    rescue Exception => e
      false
    end
  end
end