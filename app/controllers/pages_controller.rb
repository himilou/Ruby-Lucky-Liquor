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
    @image_list = []
    dir_files = []
    Dir.glob("app/assets/images/*").map do |path|
      dir_files.push(File.basename(path))
    end
    puts dir_files
      patterns_to_exclude = [ "*.ico", "*.png", "plain_t*" ]
      # Exclude any file that matches AT LEAST ONE pattern in the array
      filtered = dir_files.reject do |file|
      patterns_to_exclude.any? { |pattern| File.fnmatch(pattern, file) }
    end
    @image_list = filtered
  end

  def galleryimage
    @image_name = params[:filename].to_s
  end
  private

  def set_page_title
    @page_title = action_name.humanize
  end
end
