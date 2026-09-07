require "json"

class EventsController < ApplicationController
  # Constant to hold the path to the events.json file
  DIR_PATH = Rails.root.join("public/event_img")
  EVENTS_JSON_PATH = DIR_PATH.join("events.json")
  def events
    logger = Rails.logger
    @event_list = []
    begin
      data = JSON.parse(File.read(EVENTS_JSON_PATH.to_s))

      data.each do |event|
        @event_list << EventDetail.new(
          filename: event["filename"],
          date: event["date"],
          bandname: event["bandnames"]
        )
      end
    rescue Errno::ENOENT
      puts "File not found."
      Rails.logger.error "Error: Events Controller ould not read #{EVENTS_JSON_PATH} - file not found."
    rescue JSON::ParserError
      puts "Invalid JSON format."
      Rails.logger.error "Error: events.json file invalid."
    end
  end

  def image
    filename = params[:filename].to_s
    @image_name = File.basename(filename)
    image_file = DIR_PATH.join(filename)
    
    unless @image_name.present? && File.file?(image_file)
      raise ActionController::RoutingError, "Not Found"
      Rails.logger.error "Error: Image file not found at #{image_file}"
    end
    
    event_data = JSON.parse(File.read(EVENTS_JSON_PATH.to_s)).find { |event| event["filename"] == @image_name }
    @event_date = event_data&.dig("date")
    @event_bandname = event_data&.dig("bandnames")
  end
end

