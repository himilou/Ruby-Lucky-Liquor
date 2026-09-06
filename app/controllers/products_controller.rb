class ProductsController < ApplicationController
  # before_action :set_post, only: %i[ show edit update destroy ]
  # before_action :authenticate_user!, only: [ :new, :edit, :create, :update, :destroy ]
  def index
    @products = Product.includes(primary_image: { file_attachment: :blob }).all
  end

  def show
    prod_id = params[:id].to_i
    @product = Product.includes(:product_images).find_by(id: prod_id)

    @hello = "Hello from the products controller for product: " + prod_id.to_s
  end

  def new
    @product = Product.new
    @productImage = @product.product_images.build
  end

  def create
    permitted = product_params
    uploaded_images = (permitted.delete(:images) || []).compact_blank
    @product = Product.new(permitted)

    if @product.save
      uploaded_images.each_with_index do |uploaded_image, index|
        product_image = @product.product_images.create!(
          alt_text: product_image_params[:alt_text],
          is_primary: index.zero?
        )
        product_image.file.attach(uploaded_image)
      end
      redirect_to products_show_path(id: @product.id), notice: "Product was successfully created."
    else
      @productImage = @product.product_images.build
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    prod_id = params[:id].to_i


    @product = Product.includes(:product_images, :product_sizes).find_by(id: prod_id)

    existing_size_ids = @product.product_sizes.map(&:size_id)
    Size.where.not(id: existing_size_ids).find_each do |size|
      @product.product_sizes.build(size: size)
    end
  end

  # Processes updates to an existing product, including handling image uploads and primary image selection.
  def update
    @product = Product.find(params[:id])
    permitted = product_params
    uploaded_images = (permitted.delete(:images) || []).compact_blank
    # Grab the alt text that was already set for the product images, if any, to use for new images
    existing_alt_text = @product.product_images.where.not(alt_text: [ nil, "" ]).pick(:alt_text) || ""
    if @product.update(permitted)
       uploaded_images.each_with_index do |uploaded_image, index|
        product_image = @product.product_images.create!(
          alt_text: existing_alt_text,
          is_primary: index.zero?
        )
        product_image.file.attach(uploaded_image)
      end
      # If a primary image was chosen, reset others and set the new one
      if params[:product][:primary_image_id].present?
        @product.product_images.update_all(is_primary: false)
        @product.product_images.find(params[:product][:primary_image_id]).update(is_primary: true)
      end

      redirect_to products_show_path(id: @product.id),  notice: "Product updated successfully."
    else
      render :edit
    end
  end

  def destroy
  end

  private



  def product_params
    params.require(:product).permit(
      :product_name,
      :product_desc,
      images: [],
      product_sizes_attributes: [ :id, :size_id, :sku, :price, :stock_level, :_destroy ],
      product_images_attributes: [ :id, :is_primary, :alt_text, :file, :_destroy ] # For nested files
    )
  end

  def product_image_params
    params.fetch(:product_image, {}).permit(:alt_text, :is_primary)
  end
end
