class RenameProductImageUrlToImageFilename < ActiveRecord::Migration[8.0]
  def change
    rename_column :product_images, :product_image_url, :image_filename
  end
end
