class CreateInitialSchema < ActiveRecord::Migration[8.0]
  def change
    ActiveRecord::Schema[8.0].define(version: 2026_09_04_030000) do
    create_table "active_storage_attachments", force: :cascade do |t|
      t.string "name", null: false
      t.string "record_type", null: false
      t.bigint "record_id", null: false
      t.bigint "blob_id", null: false
      t.datetime "created_at", null: false
      t.index [ "blob_id" ], name: "index_active_storage_attachments_on_blob_id"
      t.index [ "record_type", "record_id", "name", "blob_id" ], name: "index_active_storage_attachments_uniqueness", unique: true
    end

    create_table "active_storage_blobs", force: :cascade do |t|
      t.string "key", null: false
      t.string "filename", null: false
      t.string "content_type"
      t.text "metadata"
      t.string "service_name", null: false
      t.bigint "byte_size", null: false
      t.string "checksum"
      t.datetime "created_at", null: false
      t.index [ "key" ], name: "index_active_storage_blobs_on_key", unique: true
    end

    create_table "active_storage_variant_records", force: :cascade do |t|
      t.bigint "blob_id", null: false
      t.string "variation_digest", null: false
      t.index [ "blob_id", "variation_digest" ], name: "index_active_storage_variant_records_uniqueness", unique: true
    end

    create_table "product_images", force: :cascade do |t|
      t.boolean "is_primary"
      t.string "alt_text"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "product_id", null: false
      t.index [ "product_id" ], name: "index_product_images_on_product_id"
    end

    create_table "product_sizes", force: :cascade do |t|
      t.integer "product_id", null: false
      t.integer "size_id", null: false
      t.integer "stock_level"
      t.string "sku"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.float "price"
      t.index [ "product_id" ], name: "index_product_sizes_on_product_id"
      t.index [ "size_id" ], name: "index_product_sizes_on_size_id"
    end

    create_table "products", force: :cascade do |t|
      t.string "product_name"
      t.text "product_desc"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "sizes", force: :cascade do |t|
      t.string "size"
      t.string "size_code"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
    add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
    add_foreign_key "product_images", "products"
    add_foreign_key "product_sizes", "products"
    add_foreign_key "product_sizes", "sizes"
    end
  end
end
