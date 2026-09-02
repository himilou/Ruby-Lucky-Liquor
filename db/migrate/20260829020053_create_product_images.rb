class CreateProductImages < ActiveRecord::Migration[8.0]
  def change
    create_table :product_images do |t|
      t.string :product_image_url
      t.boolean :is_primary
      t.string :alt_text
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
