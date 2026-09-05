class MerchController < ApplicationController
  # before_action :set_post, only: %i[ show edit update destroy ]
  # before_action :authenticate_user!, only: [ :new, :edit, :create, :update, :destroy ]
  def index
    @Products = Product.includes(primary_image: { file_attachment: :blob }).all
  end

  def show
    prod_id = params[:id].to_i
    @Product = Product.includes(:product_images).find_by(id: prod_id)

    @hello = "Hello from the merch controller for product: " + prod_id.to_s
  end

  def new
    @Product = Product.new
    @ProductImage = @Product.product_images.build
  end

  def create
    permitted = product_params
    uploaded_images = (permitted.delete(:images) || []).compact_blank
    @Product = Product.new(permitted)

    if @Product.save
      uploaded_images.each_with_index do |uploaded_image, index|
        product_image = @Product.product_images.create!(
          alt_text: product_image_params[:alt_text],
          is_primary: index.zero?
        )
        product_image.file.attach(uploaded_image)
      end
      redirect_to merch_show_path(id: @Product.id), notice: "Product was successfully created."
    else
      @ProductImage = @Product.product_images.build
      render :new, status: :unprocessable_entity
    end
  end

  def update
    prod_id = params[:id].to_i
    @Product = Product.with_attached_images.includes(:product_images).find_by(id: prod_id)
  end

  def destroy
  end

  private



  def product_params
    params.require(:product).permit(
      :product_name,
      :product_desc,
      images: [],
      size_ids: [], # For checking box arrays of sizes
      product_images_attributes: [ :id, :is_primary, :alt_text, :file, :_destroy ] # For nested files
    )
  end

  def product_image_params
    params.fetch(:product_image, {}).permit(:alt_text, :is_primary)
  end
end
