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
    text = Docsplit.extract_text(pathname, :pages => 1..5, :output => "/opt/scripts/" + shortname[0, shortname.length-4])

    p "Done"
    p "Converting script to Lines/Characters"
    Dir.chdir("/opt/scripts/" + shortname[0, shortname.length-4])
    text = ""
    Dir.glob("*.{txt}").each do |filename|
      page = File.open(filename, 'rb')
      text << page.read
      page.close
    end


    #try matching with "CHARACTER:"
    characters, lines = ScriptParser.fill_lines(text, /[A-Z]+([ ]|[-]|[:]|[.])+[\n]/)

    script_name = JSON.parse(response)["results"].first["name"]

    #script = Script.add_script_return(script_name, username)

    count = 0

    p text

    characters.each do
      p characters[count]
      p lines[count]
      count = count + 1
    end

    #p "Adding lines to Parse"
    #characters.each do |char|
    #  line = lines[count]
    #  Script.add_line(script, char, line)
    #  p "Added line to script #{script}, #{char}, #{line}"
    #  count = count + 1
    #end
    #p "Added Lines"

  end

  class ScriptParser
    def self.fill_lines(text, regex)
      characters = []
      lines = []

      matched = text.partition(regex)
      characters << clean_character(matched[1]) unless matched[1] == "IN:" or matched[1].size <= 2
      until matched[2] == ""
        matched = matched[2].partition(regex)
          lines << matched[0].strip.split("\n\n").first unless characters.size == 0
          character = matched[1].strip
          characters << clean_character(character)
      end

      return characters, lines
    end

    def self.clean_character(character)
      /[A-Z]{2,}/.match(character).string
    end
  end

end