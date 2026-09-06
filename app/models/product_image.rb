


class ProductImage < ApplicationRecord
  belongs_to :product, inverse_of: :product_images
  has_one_attached :file, dependent: :destroy
end
