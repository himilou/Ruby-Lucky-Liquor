class AddProductToProductImages < ActiveRecord::Migration[8.0]
  def change
    add_reference :product_images, :product, null: false, foreign_key: true
    remove_index :product_images, column: :active_storage_attachments_id
    add_index :product_images, :active_storage_attachments_id, unique: true
  end
end