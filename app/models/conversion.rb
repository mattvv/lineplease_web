class Conversion < ActiveRecord::Base
  @queue = :default

  def self.perform(objectId, username)
    site = RestClient::Resource.new SITE, APPLICATION_ID, MASTER_KEY
    response = site["/classes/Conversion"].get({:params => {:where => {"objectId" => objectId }.to_json}})
    file = JSON.parse(response)["results"].first["file"]["name"]

    shortname = File.basename(file)
    pathname = "/opt/scripts/"+shortname

    p "Downloading file..."
    require 'open-uri'
    writeOut = open(pathname, "wb")
    writeOut.write(open(file).read)
    writeOut.close

    p "Done"
    #puts text in array

    p "Extracting text..."

    begin
      length = Docsplit.extract_length(pathname)
      length = 5 if length > 5
      Docsplit.extract_text(pathname, :pages => 1..length, :output => "/opt/scripts/" + shortname[0, shortname.length-4])
    rescue Exception => e
      p e.message
    end

    p "Done"
    p "Converting script to Lines/Characters"

    begin
      Dir.chdir("/opt/scripts/" + shortname[0, shortname.length-4])
      text = ""
      pagesarray = ["","","","",""]
      pages = 0
      Dir.glob("*.{txt}").each do |filename|
        page = File.open(filename, 'rb')
        #todo fix the page extraction here:
        p "reading page #{filename}"
        actual_page = page.read
        p "read page"
        pagesarray[filename[(filename.length-5-1)]] = actual_page
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
      p e.backtracke
    end

    p text

    p "parsing the script now"

    #try matching with "CHARACTER:"
    begin
      characters, lines = ScriptParser.fill_lines(text, /[A-Z]{3,}+([ ][-]|[:]|[.])/)
    rescue Exception => e
      p e.message
    end
    script_name = JSON.parse(response)["results"].first["name"]

    script = Script.add_script_return(script_name, username)

    count = 0

    #characters.each do
    #  p characters[count]
    #  p lines[count]
    #  count = count + 1
    #end

    p "Adding lines to Parse"
    characters.each do |char|
      line = lines[count]
      unless line.nil? or char.nil?
        Script.add_line(script, char, line, "female")
        p "Added line to script #{script}, #{char}, #{line}"
      end
      count = count + 1
    end
    p "Added Lines"

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
      line = line[1, line.length] if line[0, 1] == "\n"
      line = " " if line.nil?
      line
    end
  end

end