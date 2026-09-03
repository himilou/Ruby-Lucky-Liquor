


class ProductImage < ApplicationRecord
  belongs_to :product, inverse_of: :product_images
  belongs_to :active_storage_attachment,
    class_name: "ActiveStorage::Attachment",
    foreign_key: :active_storage_attachments_id
end











=begin
class ProductImage < ApplicationRecord
  belongs_to :product
end
=end
