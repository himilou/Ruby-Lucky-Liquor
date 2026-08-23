# app/models/events.rb
class EventDetail
  # Simple ruby object that is used to pass information from the eventcontroller to the event view
  attr_reader :filename, :date, :bandname

  def initialize(filename:, date:, bandname:)
    @filename = filename
    @date = date
    @bandname = bandname
  end
end
