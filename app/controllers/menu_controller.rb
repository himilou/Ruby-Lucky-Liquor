
# Controller for menu amd menu images. Menu Files are stored in /public/menu to allow rails style URL linking
class MenuController < ApplicationController
  DIR_PATH = Rails.root.join("public/menu")

  before_action :set_page_title
  before_action :require_user, only: [ :new, :create ]

  def menu
  end

  def image
    menuname = params[:menuname].to_s
    @image_name = File.basename(menuname)
    image_file = DIR_PATH.join(@image_name)
    Rails.logger.info "Menu image name: #{@image_name}"
    unless @image_name.present? && File.file?(image_file)
      raise ActionController::RoutingError, "Not Found"
      Rails.logger.error "Menu Controller Error: Image file not found at #{image_file}"
    end
  end

  def new
  end

  def create
    uploads = [
      [ params[:image_menu_front], params[:image_name_front] ],
      [ params[:image_menu_rear], params[:image_name_rear] ],
      [ params[:image_spirit_front], params[:image_Name_spirit_front] ],
      [ params[:image_spirit_rear], params[:image_name_spirit_rear] ]
    ]

    begin
      uploads.each do |uploaded_file, submitted_filename|
        next unless uploaded_file.present?

        filename = File.basename(submitted_filename.to_s)
        next if filename.blank?

        filepath = DIR_PATH.join(filename)
        data = File.binread(uploaded_file)
        File.open(filepath, "wb") do |file|
          file.write(data)
        end
        Rails.logger.info "Menu Controller: Image #{filename} uploaded"
      end
    rescue StandardError => error
      Rails.logger.error "Menu Controller: Image upload failed: #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
      redirect_to menu_new_path, notice: "Menu image upload failed with #{error.message}"
    end

    redirect_to menu_new_path, notice: "Menu images processed."
  end

  private

  # Simple title setter works with :set_page_title_symbol
  def set_page_title
    @page_title = action_name.humanize
  end

  def image_params
    params.require(:menuimage).permit(images: [])
  end
end
