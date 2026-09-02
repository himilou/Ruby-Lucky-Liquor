# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_09_01_000000) do
  create_table "product_images", force: :cascade do |t|
    t.string "image_filename"
    t.boolean "is_primary"
    t.string "alt_text"
    t.integer "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "product_sizes", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "size_id", null: false
    t.integer "stock_level"
    t.string "sku"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "price"
    t.index ["product_id"], name: "index_product_sizes_on_product_id"
    t.index ["size_id"], name: "index_product_sizes_on_size_id"
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

  add_foreign_key "product_images", "products"
  add_foreign_key "product_sizes", "products"
  add_foreign_key "product_sizes", "sizes"
end
