class Script < ParseResource::Base
  fields :name, :username

  has_many :lines

  def self.set_order_on_all_scripts
    start = 0
    3.times do
      scripts = Script.limit(1000).skip(start).all
      puts "Ordering #{scripts.count} Scripts from #{start}"
      scripts.each do |script|
        puts "Ordering Script: Script #{script.name}"
        lines = Line.where(:scriptId => script.id).order(:createdAt).limit(1000).all
        count = 0
        lines.each do |line|
          line.position = count
          line.save
          count = count + 1
        end
      end
      start = start + 1000
    end
  end
end