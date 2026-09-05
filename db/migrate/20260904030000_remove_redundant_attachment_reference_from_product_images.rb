class RemoveRedundantAttachmentReferenceFromProductImages < ActiveRecord::Migration[8.0]
  def change
    remove_index :product_images, column: :active_storage_attachments_id
    remove_column :product_images, :active_storage_attachments_id, :integer
  end
end
