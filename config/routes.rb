Rails.application.routes.draw do
  get "products", to: "products#index"
  get "products/index"
  get "products/show"
  get "products/new"
  post "products/create", as: :products_create
  get "products/edit", as: :products_edit
  patch "products/update", as: :products_update
  delete "products/destroy", as: :products_destroy

  root "pages#home"

  get "events", to: "events#events"
  get "events/image", to: "events#image", as: :events_image
  get "menu", to: "pages#menu"
  get "press", to: "pages#press"
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
  get "gallery", to: "pages#gallery"

  get "up" => "rails/health#show", as: :rails_health_check
end
