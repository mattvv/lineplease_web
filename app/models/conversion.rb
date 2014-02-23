class Conversion < ParseResource::Base
  @queue = :default
  fields :name, :scriptId, :file, :percent, :error

  def self.perform(objectId, username)
    p "Getting conversoin #{objectId}"
begin
    @conversion = Conversion.find(objectId)
rescue Exception => e
  puts "error #{e.message}"
  puts "stacktrace: #{e.backtrace.join("\n")}"
end
    p "getting resource #{SITE} #{APPLICATION_ID} #{MASTER_KEY}"
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    p "got site #{site}"
    response = site["/classes/Conversion"].get({:params => {:where => {"objectId" => objectId }.to_json}})
    p "calling out to get the conversionw ith objectID #{objectId}"

    file = JSON.parse(response)["results"].first["file"]["url"]

    p "downloading file #{JSON.parse(response)["results"].first["file"]}"

    shortname = File.basename(file)
    pathname = "/opt/scripts/"+shortname

    begin
      p "Downloading file..."
      @conversion.status = "Downloading Script to Process..."
      @conversion.percent = 10
      @conversion.save
    rescue Exception => e
      p e.message
    end

    require 'open-uri'
    writeOut = open(pathname, "wb")
    writeOut.write(open(file).read)
    writeOut.close

    p "Done"
    #puts text in array

    @conversion.status = "Extracting text..."
    @conversion.percent = 20
    @conversion.save
    begin
      length = Docsplit.extract_length(pathname)
      length = 5 if length > 5
      Docsplit.extract_text(pathname, :pages => 1..length, :output => "/opt/scripts/" + shortname[0, shortname.length-4])
    rescue Exception => e
      p e.message
    end
    @conversion.status = "Ordering Pages..."
    @conversion.percent = 60
    @conversion.save
    p "Done"
    p "Converting script to Lines/Characters"
    pagesarray = []
    begin
      Dir.chdir("/opt/scripts/" + shortname[0, shortname.length-4])
      text = ""
      pages = 0
      length.times do |index|
        current_page = index + 1
	shortname = shortname[0,shortname.length-1] if shortname[shortname.length-1,shortname.length] == "x"
        p "Opening " + shortname[0, shortname.length-4] + "_#{current_page}.txt"
        page = File.open(shortname[0, shortname.length-4] + "_#{current_page}.txt", 'rb')
        #todo fix the page extraction here:
        actual_page = page.read
        actual_page = actual_page.force_encoding('UTF-8')
        #actual_page = actual_page.encode('UTF-16le', :invalid => :replace, :replace => '').encode('UTF-8')
        p "read page"
        pagesarray << actual_page
        p "Adding page to array"
        page.close
        p "page #{pages} is #{actual_page}"
        p "Encoding is #{actual_page.encoding}"
        p "closed page #{pages}"
        pages = pages + 1
      end

      pagesarray.each do |thepage|
        text << thepage
      end
    rescue Exception => e
      p e.message
      @conversion.error = e.message
      @conversion.save
      p e.backtracke
    end

    p text
    @conversion.status = "Arranging Characters and lines..."
    @conversion.percent = 75
    @conversion.save
    p "parsing the script now"

    #try matching with "CHARACTER:"
    begin
      characters, lines = ScriptParser.fill_lines(text, /[A-Z]{3,}+([ ]||[-]|[:]|[.])/)
      #characters, lines = ScriptParser.fill_lines(text.force_encoding("UTF-8"), /\P{Ll}{3,}+([ ]|[-]|[:]|[.])/)
    rescue Exception => e
      p e.message
    end

    script = Script.new
    script.name = @conversion.name
    script.username = username
    script.save
    @conversion.scriptId = script.id
    @conversion.status = "Putting Lines into Script..."
    @conversion.percent = 85
    @conversion.save
    count = 0

    #characters.each do
    #  p characters[count]
    #  p lines[count]
    #  count = count + 1
    #end
    p "character count is #{characters.count}"
    index = 0
    p "Adding lines to Parse"
    characters.each do |char|
      p "index is #{index}"
      line = lines[index]
      unless line.nil? or char.nil?
        line = line.force_encoding('UTF-8')
        line.gsub!(/[^0-9a-z ]/i, '')
        char.gsub!(/[^0-9a-z ]/i, '')
        p "parsing line #{line}"
        l = Line.new
        l.scriptId = script.id
        l.character = char
        l.gender = "female"
        l.line = line
        l.position = index
        l.save
        p "Added line to script #{script}, #{char}, #{line}"
      end
      puts "adding index"
      index = index + 1
    end
    p "Added Lines"
    @conversion.status = "Completed"
    @conversion.percent = 100
    @conversion.save
    p "Updated Status to 100"

  end

  class ScriptParser
    def self.fill_lines(text, regex)
      characters = []
      lines = []

      matched = text.partition(regex)
      char = clean_character(matched[1])
      characters << char unless char == "IN" or char.nil? or char.size < 2
      until matched[2] == ""
        matched = matched[2].partition(regex)
          lines << clean_line(matched[0]) unless characters.nil? or characters.size == 0
          character = matched[1].strip
          characters << clean_character(character)
      end

      if characters.count == 0
        # we have no characters, lets be a little more loose on the conversion!

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
