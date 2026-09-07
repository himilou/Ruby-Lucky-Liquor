require "json"
require "fileutils"

namespace :images do
  desc "Parse event images from directory and export to a JSON file"
  task parse_to_json: :environment do
    # 1. Define configuration paths
    # dir_path = "home/himilou/Source/ruby/lucky/app/assets/images/event_img"
    dir_path = Rails.root.join("public/event_img")
    json_output_path = dir_path.join("events.json")

    # Check if the source directory actually exists
    unless Dir.exist?(dir_path)
      err_string = "Error: Source directory does not exist at '#{dir_path}'"
      abort err_string
      Rails.logger.error err_string
    end

    puts "Scanning directory: #{dir_path}..."

    # 2. Gather matching image files (ignoring directories)
    image_paths = Dir.glob("#{dir_path}/*.{jpg,jpeg,png,gif,webp}", File::FNM_CASEFOLD).select do |file|
      File.file?(file)
    end

    if image_paths.empty?
      Rails.logger.info "No matching image files found."
      next
    end

    # 3. Parse components out of the filename strings
    parsed_files = image_paths.map do |path|
      filename = File.basename(path)
      extension = File.extname(filename).delete(".")
      basename_without_ext = File.basename(filename, ".*")

      # Regex splits the leading date pattern from the trailing names
      if basename_without_ext =~ /^([\d\.]+)(?:\s+(.*))?$/
        date = $1
        name = $2.to_s
      else
        date = ""
        name = basename_without_ext
      end

      {
        filename: filename,
        date: date,
        bandnames: name,
        extension: extension
      }
    end
    current_files = []
    parsed_files.each do |file|
      keepday = Date.today - 2
      showdate = Date.strptime(file[:date], "%m.%d.%y") rescue nil
      if showdate && showdate < keepday
        remove_file = dir_path.join(file[:filename])
        File.delete(remove_file) if File.exist?(remove_file)
        puts "Deleted old file: #{remove_file}"
      else
        current_files << file
      end
    end
    # Sort the current files by date (descending)
    current_files = current_files.sort_by { |file| file[:date].gsub(".", "").to_i }

    # 4. Write formatted payload to disk
    puts json_output_path
    File.open(json_output_path, "w") do |f|
      f.write(JSON.pretty_generate(current_files))
    end
    info_string = "Task complete! Successfully processed #{current_files.size} files into '#{json_output_path}'."
    puts info_string
    Rails.logger.info info_string
  end
end
