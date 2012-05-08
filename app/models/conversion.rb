class Conversion < ParseResource::Base
  @queue = :default
  fields :name, :scriptId, :file, :percent, :error

  def self.perform(objectId, username)
    self.reload
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    response = site["/classes/Conversion"].get({:params => {:where => {"objectId" => objectId }.to_json}})
    file = JSON.parse(response)["results"].first["file"]["name"]

    shortname = File.basename(file)
    pathname = "/opt/scripts/"+shortname

    begin
      p "Downloading file..."
      update_attribute(:status, "Downloading Script to Process...")
      update_attribute(:percent, 5)
    rescue Exception => e
      p e.message
    end

    require 'open-uri'
    writeOut = open(pathname, "wb")
    writeOut.write(open(file).read)
    writeOut.close

    p "Done"
    #puts text in array

    update_attribute(:status, "Extracting text...")
    update_attribute(:percent, 10)
    begin
      length = Docsplit.extract_length(pathname)
      length = 5 if length > 5
      Docsplit.extract_text(pathname, :pages => 1..length, :output => "/opt/scripts/" + shortname[0, shortname.length-4])
    rescue Exception => e
      p e.message
    end
    update_attribute(:status, "Ordering Pages...")
    update_attribute(:percent, 40)
    p "Done"
    p "Converting script to Lines/Characters"
    pagesarray = []
    begin
      Dir.chdir("/opt/scripts/" + shortname[0, shortname.length-4])
      text = ""
      pages = 0
      length.times do |index|
        current_page = index + 1
        p "Opening " + shortname[0, shortname.length-4] + "_#{current_page}.txt"
        page = File.open(shortname[0, shortname.length-4] + "_#{current_page}.txt", 'rb')
        #todo fix the page extraction here:
        actual_page = page.read
        p "read page"
        pagesarray << actual_page
        p "Adding page to array"
        page.close
        p "page #{pages} is #{actual_page}"
        p "closed page #{pages}"
        pages = pages + 1
      end

      pagesarray.each do |thepage|
        text << thepage
      end
    rescue Exception => e
      p e.message
      update_attribute(:error, e.message)
      p e.backtracke
    end

    p text
    update_attribute(:status, "Arranging Characters and lines...")
    update_attribute(:percent, 60)
    p "parsing the script now"

    #try matching with "CHARACTER:"
    begin
      characters, lines = ScriptParser.fill_lines(text, /[A-Z]{3,}+([ ][-]|[:]|[.])/)
    rescue Exception => e
      p e.message
    end
    script_name = JSON.parse(response)["results"].first["name"]

    script = Script.new
    script.name = script_name
    script.username = username
    script.save
    update_attribute(:scriptId, script.object_id)
    update_attribute(:status, "Putting Lines into Script...")
    update_attribute(:percent, 75)
    count = 0

    #characters.each do
    #  p characters[count]
    #  p lines[count]
    #  count = count + 1
    #end

    p "Adding lines to Parse"
    characters.each do |char, index|
      line = lines[index]
      unless line.nil? or char.nil?
        line = Line.new
        line.scriptId = script.id
        line.character = char
        line.gender = "female"
        line.line = line
        line.position = index
        line.save
        p "Added line to script #{script}, #{char}, #{line}"
      end
    end
    p "Added Lines"
    update_attribute(:status, "Successful!")
    update_attribute(:percent, 100)

  end

  class ScriptParser
    def self.fill_lines(text, regex)
      characters = []
      lines = []

      matched = text.partition(regex)
      char = clean_character(matched[1])
      characters << char unless char == "IN" or char.size <= 2
      until matched[2] == ""
        matched = matched[2].partition(regex)
          lines << clean_line(matched[0]) unless characters.size == 0
          character = matched[1].strip
          characters << clean_character(character)
      end

      return characters, lines
    end

    def self.clean_character(character)
      char = /[A-Z]{2,}/.match(character)
      char.try(:to_s)
    end

    def self.clean_line(line)
      line = line.strip
      line = line.gsub(/\([^)]*\)/, "")
      until line[0, 1] != "\n" and line[0, 1] != "." and line[0, 1] != " "
        line = line[1, line.length]
      end
      line = " " if line.nil?
      line
    end
  end

end