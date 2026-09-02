class Product < ApplicationRecord
  # has_many :product_images, dependent: :destroy
  has_one :product_image, -> { where(is_primary: true).order(:created_at) },
    class_name: "ProductImage",
    inverse_of: :product,
    dependent: :destroy
end
