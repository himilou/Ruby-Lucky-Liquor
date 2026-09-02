class AddPriceToProductSizes < ActiveRecord::Migration[8.0]
  def change
    add_column :product_sizes, :price, :float
  end
end