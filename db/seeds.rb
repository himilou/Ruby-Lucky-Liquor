# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Seed our products database

def create_products
  Product.find_or_create_by!(product_name: "Lucky skull and bones") do |product|
    product.product_desc = "classic lucky liquor t shirt"
  end

  Product.find_or_create_by!(product_name: "Lucky plain T") do |product|
    product.product_desc = "black t shirt"
  end

  puts "Created or ensured 2 products"
end


def create_sizes
  shirt_sizes = [ [ "Small", "S" ], [ "Medium", "M" ], [ "Large", "L" ] ]

  shirt_sizes.each do |size_name, size_code|
    Size.find_or_create_by!(size: size_name) do |size|
      size.size_code = size_code
    end
  end

  puts "Created or ensured sizes"
end


def create_image
  plain_t_path = Rails.root.join("app/assets/images/merch/plain_t.jpeg")
  product = Product.find_by(product_name: "Lucky plain T")

  return unless product
  return unless plain_t_path.exist?

  ProductImage.find_or_create_by!(product_id: product.id) do |image|
    image.product_image_url = plain_t_path.to_s
    image.is_primary = true
    image.alt_text = "plain black tee"
  end

  puts "Created or ensured product image"
end


def create_product_sizes
  product_names = [ "Lucky skull and bones", "Lucky plain T" ]

  product_names.each do |product_name|
    product = Product.find_by(product_name: product_name)
    next unless product

    Size.find_each do |size|
      ProductSize.find_or_create_by!(product_id: product.id, size_id: size.id) do |product_size|
        product_size.stock_level = 1
        product_size.price = 20.0
        product_size.sku = "#{product.id}-#{size.size_code}"
      end
    end
  end

  puts "Created or ensured product stock entries for each size on both products"
end


def create_basic_items
  create_products
  create_sizes
  create_product_sizes
  create_image
end


def clear_tables
  Product.destroy_all
  Size.destroy_all
  ProductImage.destroy_all
  ProductSize.destroy_all
  puts "All merchandise tables cleared"
end

create_basic_items
