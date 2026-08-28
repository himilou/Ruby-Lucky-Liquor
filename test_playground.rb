
 require 'json'
 require "fileutils"
 require 'pathname'
 require 'rails'

 # ruby file to test code outside of framework

 class EventDetail
    # Simple ruby object that is used to pass information from the eventc ontroller to the event view
    attr_reader :filename, :date, :bandnames

    def initialize(filename, date,  bandnames)
      @filename = filename
      @date = date
      @bandnames = bandnames
    end
 end

 def events
  logger = Rails.logger
    begin
      dir_path = Pathname.new('/home/himilou/Source/ruby/lucky/app/assets/images/event_img')
      # dir_path = Rails.root.join("app/assets/images/event_img")
      json_path = dir_path.join("events.json")
      data = JSON.parse(File.read(json_path))

    rescue Errno::ENOENT
      puts "File not found."
      logger.warn "Warning: Could not read events.json"
    rescue JSON::ParserError
      puts "Invalid JSON format."
      logger.warn "Warning events.json file invalid."
    end

    event_list = []
    data.each  do | event |
      # puts event["filename"]
      myclass = EventDetail.new(event["filename"], event["date"], event["bandnames"])
      event_list.push(myclass)
    end
    event_list
 end


list = events
list.each do |evt|
  puts evt.bandnames
end
