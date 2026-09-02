class CreateProductSizes < ActiveRecord::Migration[8.0]
  def change
    create_table :product_sizes do |t|
      t.references :product, null: false, foreign_key: true
      t.references :size, null: false, foreign_key: true
      t.integer :stock_level
      t.string :sku

      t.timestamps
    end
  end
end
