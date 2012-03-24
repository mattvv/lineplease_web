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
end