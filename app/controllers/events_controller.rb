require "json"

class EventsController < ApplicationController
  def events
    logger = Rails.logger
    @event_list = []

    begin
      dir_path = Rails.root.join("app/assets/images/event_img")
      json_path = dir_path.join("events.json")
      data = JSON.parse(File.read(json_path))

      data.each do |event|
        @event_list << EventDetail.new(
          filename: event["filename"],
          date: event["date"],
          bandname: event["bandnames"]
        )
      end
    rescue Errno::ENOENT
      puts "File not found."
      logger.warn "Warning: Could not read events.json"
    rescue JSON::ParserError
      puts "Invalid JSON format."
      logger.warn "Warning events.json file invalid."
    end
  end

  def image
    filename = params[:filename].to_s
    @image_name = File.basename(filename)
    @image_path = "event_img/#{@image_name}"
    @image_file = Rails.root.join("app/assets/images", @image_path)

    unless @image_name.present? && File.file?(@image_file)
      raise ActionController::RoutingError, "Not Found"
    end

    json_path = Rails.root.join("app/assets/images/event_img/events.json")
    event_data = JSON.parse(File.read(json_path)).find { |event| event["filename"] == @image_name }

    @event_date = event_data&.dig("date")
    @event_bandname = event_data&.dig("bandnames")
  end
end
