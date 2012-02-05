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
      text = Docsplit.extract_text(pathname, :pages => 1..5, :output => "/opt/scripts/" + shortname[0, shortname.length-4])
    rescue Exception => e
      p e.message
    end

    p "Done"
    p "Converting script to Lines/Characters"
    Dir.chdir("/opt/scripts/" + shortname[0, shortname.length-4])
    text = ""
    Dir.glob("*.{txt}").each do |filename|
      page = File.open(filename, 'rb')
      text << page.read
      page.close
    end

    p text

    p "parsing the script now"

    #try matching with "CHARACTER:"
    begin
      characters, lines = ScriptParser.fill_lines(text, /[A-Z]+([ ]|[-]|[:]|[.]|)+[\n]/)
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
      Script.add_line(script, char, line)
      p "Added line to script #{script}, #{char}, #{line}"
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
      line = line.strip.split("\n\n").first
      line = line.gsub(/\([^)]*\)/, "")
      line = line[1, line.length] if line[0, 1] == "\n"
      line
    end
  end

end