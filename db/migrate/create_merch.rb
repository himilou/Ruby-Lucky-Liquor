



# db migration table for the products models
#
class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :product_name
      t.string :product_desc
      t.timestamps :created_at
    end
  end
end


class CreateProductImages < ActiveRecord::Migration[8.0]
  def change
    create_table :product_images do |t|
      t.references :product, null: false, foreign_key: true, index: { unique: true }
      t.string :product_image_url
      t.bool :is_primary
      t.string :alt_text
    end
  end
end

class CreateSizes < ActiveRecord::Migration[8.0]
  def change
    create_table :sizes do |t|
      t.string :size
      t.string :size_code  # ( S, M, XL)
    end
  end
end



class CreateProductSizes < ActiveRecord::Migration[8.0]
   def change
    create_table :product_sizes do |t|
      t.references :product, null: false, foreign_key: true
      t.references :size, null: false, foreign_key: true
      t.integer :stock_level, default: 0, null: false
      t.string :sku, null: false, default: 'unknown' # Unique SKU per product-size combination. CAn be null or defualt unknown
      t.timestamps
    end
    add_index :product_sizes, [ :product_id, :size_id ], unique: true
    add_index :product_sizes, :sku, unique: true
  end
end
