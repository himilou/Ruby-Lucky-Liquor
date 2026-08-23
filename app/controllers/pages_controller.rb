class PagesController < ApplicationController
  before_action :set_page_title

  def home
    @hours = [
      "MON: 11A - 10P",
      "TUES: 11A - 10P",
      "WED: 11A - 10P",
      "THURS: 11A - 11P",
      "FRI: 11A - 11P",
      "SAT: 11A-11P",
      "SUN: 11A - 9P"
    ]
  end

  def menu
  end

  def press
  end

  def about
  end

  def contact
  end

  def gallery
  end

  private

  def set_page_title
    @page_title = action_name.humanize
  end
end
