require "cgi"
require "fileutils"
require "json"
require "open-uri"

namespace :images do
  file_count = 4
  desc "Download two images at a time from the public Google Drive folder into public/event_img"
  task sync_from_google_drive: :environment do
    d = DateTime.now
    d.strftime("%d/%m/%Y %H:%M")
    dstr = "Image_downloader starting at: #{d}"
    puts dstr
    Rails.logger.info dstr
    folder_id = "1fS_IYqKFABFkozIT6JPtqikZMgqwHL9B"
    target_dir = Rails.root.join("public/event_img")
    FileUtils.mkdir_p(target_dir)

    file_entries = fetch_google_drive_entries(folder_id)
    downloaded_names = downloaded_event_names(target_dir)
    file_entries = file_entries.reject { |entry| downloaded_names.include?(sanitize_drive_image_name(entry[:name])) }
    # Stop the autopromotix file from downloading
    file_entries = file_entries.reject { |entry| entry[:name].downcase.include?("autopromo".downcase) }
    # Don't download events more than 2 days old
    file_entries = file_entries.reject { |entry| previous_events(entry[:name]) }

    if file_entries.empty?
      puts "No new image files to download. Already synced from events.json."
      Rails.logger.info "Image_downloader: No new image files to download. Already synced from events.json."
      return
    end

    # not currently implimented index file is empty or missing, so we will start from the beginning of the list
    index_file = Rails.root.join("tmp/google_drive_image_index.txt")
    current_index = if index_file.exist?
      index_file.read.to_i
    else
      0
    end

    batch = file_entries.rotate(current_index).first(file_count)
    if batch.empty?
      batch = file_entries.first(file_count)
      current_index = 0
    end

    downloaded_count = 0
    pause_time = rand(1..10)
    puts "sleeping #{pause_time}..."
    sleep pause_time

    batch.each do |entry|
      puts "Downloading #{entry[:name]}"
      downloaded = download_google_drive_image(entry[:id], entry[:name], target_dir)
      pause_time = rand(5..20)
      puts "Resting between downloads for #{pause_time}"
      sleep pause_time
      downloaded_count += 1 if downloaded
    end

    next_index = (current_index + downloaded_count) % file_entries.length
    index_file.write(next_index.to_s)

    puts "Downloaded #{downloaded_count} image(s) from Google Drive. Next index: #{next_index}"
    Rails.logger.info "Image_downloader: Downloaded #{downloaded_count} image(s) from Google Drive. Next index: #{next_index}"
  end

  def fetch_google_drive_entries(folder_id)
    folder_url = "https://drive.google.com/embeddedfolderview?id=#{folder_id}#list"

    begin
      html = URI.open(folder_url, "User-Agent" => "Mozilla/5.0", read_timeout: 30, open_timeout: 30).read
    rescue OpenURI::HTTPError, Net::ReadTimeout, Timeout::Error, SocketError, Errno::ECONNRESET => e
      puts "Could not fetch Google Drive folder listing: #{e.class} - #{e.message}"
      Rails.logger.warn "Image_downloader: Could not fetch Google Drive folder listing: #{e.class} - #{e.message}"
      return []
    end

    entries = []
    html.scan(/<div class="flip-entry" id="entry-([A-Za-z0-9_-]+)"[^>]*>.*?<div class="flip-entry-title">([^<]+)<\/div>/m) do |file_id, title|
      name = sanitize_drive_image_name(title)
      entries << { id: file_id, name: name }
    end

    entries.uniq { |entry| entry[:id] }
  end

  def previous_events(title)
    today = Date.today
    # Subtract 2 days to include recently hosted events
    today = today - 2

    filename = File.basename(title.to_s.strip)
    extension = File.extname(filename).delete(".")
    basename_without_ext = File.basename(filename, ".*")

    # Regex splits the leading date pattern from the trailing names
    if basename_without_ext =~ /^([\d\.]+)(?:\s+(.*))?$/
      date = $1
      # name = $2.to_s
    else
      date = ""
      # name = basename_without_ext
    end
    showdate = Date.strptime(date, "%m.%d.%y")

    showdate < today
  end

  def sanitize_drive_image_name(title)
    name = CGI.unescapeHTML(title.to_s.strip)
    name = name.gsub(/[\r\n]+/, " ").squeeze(" ").strip
    name = name.gsub(/[<>:"\/\\|?*]+/, "_")
    name = name.gsub(/\s+/, " ")
    name = name.empty? ? "drive_image" : name
    if name == "drive_image"
      Rails.logger.info "Image_downloader: file name issue with title '#{title}'"
    end
    name
  end

  def downloaded_event_names(target_dir)
    json_path = target_dir.join("events.json")
    return [] unless json_path.exist?

    JSON.parse(json_path.read).filter_map do |event|
      filename = event["filename"].to_s.strip
      next if filename.empty?

      sanitize_drive_image_name(filename)
    rescue JSON::ParserError
      nil
    end
  end

  def download_google_drive_image(file_id, preferred_name, target_dir)
    download_url = "https://drive.google.com/uc?export=view&id=#{file_id}"

    begin
      file = URI.open(download_url, "User-Agent" => "Mozilla/5.0", read_timeout: 30, open_timeout: 30)
    rescue OpenURI::HTTPError, Net::ReadTimeout, SocketError, Errno::ECONNRESET => e
      puts "Skipping #{file_id}: #{e.class} - #{e.message}"
      Rails.logger.warn "Image_downloader: Skipping #{file_id}: #{e.class} - #{e.message}"
      return false
    end

    content_type = file.meta["content-type"].to_s
    ext = case content_type
    when /jpeg/i then "jpg"
    when /png/i then "png"
    when /gif/i then "gif"
    when /webp/i then "webp"
    else "jpg"
    end

    filename = build_download_filename(preferred_name, ext)
    File.binwrite(target_dir.join(filename), file.read)
    puts "Saved #{filename}"
    true
  end

  def build_download_filename(preferred_name, ext)
    base_name = sanitize_drive_image_name(preferred_name)
    base_name = base_name.sub(/\.#{Regexp.escape(ext)}$/i, "")
    name = base_name.empty? ? "event_image" : base_name
    "#{name}.#{ext}"
  end
end
