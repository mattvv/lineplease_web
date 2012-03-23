class Script < ParseResource::Base
  fields :name, :username

  has_many :lines
end