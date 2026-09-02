class MerchController < ApplicationController
  # before_action :set_post, only: %i[ show edit update destroy ]
  # before_action :authenticate_user!, only: [ :new, :edit, :create, :update, :destroy ]
  def index
    @Products = Product.includes(:primary_image)
    # @Products = Product.all
  end

  def show
    prod_id = params[:id].to_i
    @Product = Product.includes(:product_images).find_by(id: prod_id)

    @hello = "Hello from the merch controller for product: " + prod_id.to_s
  end

  def update
  end

  def destroy
  end
end
