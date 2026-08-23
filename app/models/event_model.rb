# app/models/events.rb
class EventDetail
  # Simple ruby object that is used to pass information from the eventcontroller to the event view
  attr_reader :filename, :date, :bandnames

  def initialize(filename, date,  bandnames)
    @filename = filename
    @date = date
    @bandnames = bandnames
  end
end
