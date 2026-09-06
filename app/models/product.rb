
=begin
class Product < ApplicationRecord
  has_many :product_images, dependent: :destroy


  # reutrns the primary image for the product, if it exists using the :primary_image tag
  # has_one :primary_product_image, -> { where(is_primary: true) }, class_name: 'ProductImage'
  has_one :primary_image, -> { where(is_primary: true) },
    class_name: "ProductImage",
    inverse_of: :product,
    dependent: :destroy
end

=end

class Product < ApplicationRecord
  has_many :product_images, dependent: :destroy
  # returns the primary image for the product, if it exists using the :primary_image tag
  has_one :primary_image, -> { where(is_primary: true) },
    class_name: "ProductImage",
    inverse_of: :product,
    dependent: :destroy

  has_many :product_sizes, dependent: :destroy
  has_many :sizes, through: :product_sizes


  accepts_nested_attributes_for :product_images, allow_destroy: true
  accepts_nested_attributes_for :product_sizes, allow_destroy: true

  validates :product_name, :product_desc,  presence: true
  # Optional: Validate image types or quantities
  # validates :images, content_type: [:png, :jpg, :jpeg], size: { less_than: 5.megabytes }
end
