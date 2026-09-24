


class UserNotFoundError < StandardError; end
class UserExistsError < StandardError; end
class FileStorageError < StandardError; end
# user hash example {username {pwhash: "wr324*7", created: "01-01-2026T12:00", modified: "01-01-2026T12:00"}


User = Struct.new(:id, :username, :pwhash, :created, :modified)

class JsonUser
  FILE_NAME = Rails.root.join("storage/user.json")

  def initialize
    @users = []
    if File.exist?(FILE_NAME)
      data = File.read(FILE_NAME)
      @users = JSON.parse(data, symbolize_names: true).map do |user|
        User.new(user[:id], user[:username], user[:pwhash], user[:created], user[:modified])
      end
    end
  end

  def update_pw(username, new_password)
    usr = @users.find { |u| u.username == username }
    if usr
      usr.pwhash =  hash_password(new_password)
      usr.modified = Time.now
    else
      raise UserNotFoundError, "User #{username} not found."
    end
    json = @users.map(&:to_h).to_json
    File.write(FILE_NAME, json)
    Rails.logger.info("#{usr.username} updated password")
    usr
  rescue SystemCallError => e
    raise FileStorageError, "JsonUser: Failed to update file. Original error: #{e.message}"
     Rails.logger.error("JsonUser #{usr.username} password update failed")
  end


  def create_user(name, password)
    if @users.find { |u| u.username == name }
      raise UserExistsError, "user #{name} already exisits"
    end
    hash = hash_password(password)
    @users << User.new(@users.size + 1, name, hash, Time.now.to_s, Time.now.to_s)
    json =  @users.map(&:to_h).to_json
    File.write(FILE_NAME, json)
     Rails.logger.info("JsonUser created new user #{name} ")
  rescue SystemCallError => e
    raise FileStorageError, "JsonUser: Failed to write file. Original error: #{e.message}"
    Rails.logger.error("JsonUser: Failed to write file. Original error: #{e.message}")
  end

  def find_by_id(userid)
    @users.find { |user| user.id == userid }
  end

  def find_by_name(name)
    @users.find { |user| user.username == name }
  end

  # Bcrypt hashing functions
  def hash_password (password)
    BCrypt::Password.create(password).to_s
  end

  def test_password(password, hash)
    BCrypt::Password.new(hash) == password   #== is overridden allowing for test vs comparing password plain to hash
  end

  # a user hash or nil
  # private_class_method def self.find_user(name)
  #   userlist.each do |u|
  #     if u.username == name
  #       user = { username: u.username, pwhash: u.pwhash, created: u.created, modified: u.modified }
  #     end
  #   end
  #   return user
  # end
end
