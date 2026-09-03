class DropProductImages < ActiveRecord::Migration[8.0]
  def change
    drop_table :product_images, if_exists: true


    create_table :product_images do |t|
      # t.integer :id
      t.boolean :is_primary
      t.string :alt_text
      t.integer :active_storage_attachments_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.references :active_storage_attachments, null: false, foreign_key: true
    end
  end
end
