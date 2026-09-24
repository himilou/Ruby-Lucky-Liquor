

class JsonOpenClose
 FILE_NAME = Rails.root.join("storage/open_close.json")

 INITIAL_HOURS = [
    { day: "Monday", opentime: "11A", closetime: "10P" },
    { day: "Tuesday", opentime: "11A", closetime: "10P" },
    { day: "Wednesday", opentime: "11A", closetime: "10P" },
    { day: "Thursday", opentime: "11A", closetime: "10P" },
    { day: "Friday", opentime: "11A", closetime: "11P" },
    { day: "Saturday", opentime: "11A", closetime: "11P" },
    { day: "Sunday", opentime: "11A", closetime: "9P" }
].freeze

  def write_json(json)
    begin
      File.write(@filename.to_s, JSON.dump(json))
    rescue => e
      msg = "write_json failed to write #{@filename} #{e.message}"
      Rails.logger.error(msg)
      puts msg
      raise FileWriteError, msg
    else
      msg = "write_json wrote #{@filename}"
      Rails.logger.info(msg)
      puts msg
    end
  end


  def initialize
    @filename = FILE_NAME
    @initial_hours = INITIAL_HOURS
    # check and see if the file exists if not create it
    if ! File.file?(@filename.to_s)
      begin
        write_json(@initial_hours)
      rescue
        msg = "json_open_close initialize failed to create #{@filename}"
        Rails.logger.error(msg)
        puts msg
      else
        msg = "json_open_close created new #{@filename}"
        Rails.logger.info(msg)
        puts msg
      end
    end
  end

  def get
    begin
      data = File.read(@filename.to_s)

    rescue
      msg = "json_open_close get: error reading #{@filename} returning initial hours"
      Rails.logger.info(msg)
      puts msg
      json_hours = @initial_hours

    else
      json_hours = JSON.parse(data)

    end
  end

 def update(new_hours)
    begin
      write_json(new_hours)

    rescue
      msg = "json_open_close update: error writing updated hours to #{@filename}"
      Rails.logger.error(msg)
      puts msg

    else
      msg = "json_open_close update: updated hours to #{@filename}"
      Rails.logger.info(msg)
      puts msg
    end
  end
end
