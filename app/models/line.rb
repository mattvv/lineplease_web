class Line < ParseResource::Base
  fields :character, :gender, :line, :recorded, :recordingFile, :scriptId, :position

  belongs_to :script

  #after_save :update_character_gender

  def update_character_gender

  end

  def update_position(new_position)
    #todo: work out all lines between positions
    #todo: between previous spot and new spot up 1
    #todo: or if moving up move all lines between preivou spot and new spot down 1
    change = self.position.to_i - new_position.to_i

    if (change < 0)
      #line has moved down change spots
      change = change * -1 #flip sign to determine how many spots
      change = change + 1
      starting_position = self.position.to_i + 1
      self.position = new_position + 1
      self.save
      change.times do
        line = Line.where(:scriptId => self.scriptId).where(:position => starting_position).first
        line.position = line.position - 1
        line.save
        starting_position = starting_position+1
      end
    else
      #line has moved up change spots
      change = change + 1
      starting_position = self.position.to_i - 1
      self.position = new_position
      self.save
      change.times do
        line = Line.where(:scriptId => self.scriptId).where(:position => starting_position).first
        line.position = line.position + 1
        line.save
        starting_position = starting_position-1
      end

    end
  end

  def self.clean_lines
    #todo: script in checking of scripts that have been deleted


    #clean lines that don't have a script
    lines = Line.where(:scriptId => nil).count
    puts "Lines that don't have a script: #{lines}"
    lines = (lines / 1000) + 1
    count = 0

    lines.times do
      the_lines = Line.where(:scriptId => nil).limit(1000)
      the_lines.each do |the_line|
        count = count + 1
        puts "deleting line #{count}"
        the_line.destroy unless the_line.id.nil?
      end
    end

    #clean lines that don't have a line
    lines = Line.where(:line => nil).count
    puts "Lines that don't have a Line: #{lines}"
    lines = (lines / 1000) + 1
    count = 0

    lines.times do
      the_lines = Line.where(:line => nil).limit(1000)
      the_lines.each do |the_line|
        count = count + 1
        puts "deleting line #{count} "
        the_line.destroy unless the_line.id.nil?
      end
    end

    #clean lines that don't have a character
    lines = Line.where(:character => nil).count
    puts "Lines that don't have a script: #{lines}"
    lines = (lines / 1000) + 1
    count = 0

    lines.times do
      the_lines = Line.where(:character => nil).limit(1000)
      the_lines.each do |the_line|
        count = count + 1
        puts "deleting line #{count}"
        the_line.destroy unless the_line.id.nil?
      end
    end

  end
end