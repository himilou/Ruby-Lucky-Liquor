class Product < ApplicationRecord
  has_many :product_images, dependent: :destroy


  # reutrns the primary image for the product, if it exists using the :primary_image tag
  # has_one :primary_product_image, -> { where(is_primary: true) }, class_name: 'ProductImage'
  has_one :primary_image, -> { where(is_primary: true) },
    class_name: "ProductImage",
    inverse_of: :product,
    dependent: :destroy
end
