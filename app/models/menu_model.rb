# app/models/menu_model.rb
class MenuDetail
  # Simple ruby object that is used to pass information from the eventcontroller to the event view
  attr_reader :menuname

  def initialize(menuname)
    @@menuname = menuname
  end
end
