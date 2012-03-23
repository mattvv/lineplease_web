class Line < ParseResource::Base
  fields :character, :gender, :line, :recorded, :recordingFile, :scriptId

  belongs_to :script

  #after_save :update_character_gender

  def update_character_gender

  end
end