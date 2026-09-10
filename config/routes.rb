Rails.application.routes.draw do
  root "pages#home"

  get "menu", to: "pages#menu"
  get "press", to: "pages#press"
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
  get "gallery", to: "pages#gallery", as: :gallery
  get "galleryimage", to: "pages#galleryimage", as: :gallery_image
  get "up" => "rails/health#show", as: :rails_health_check


  get "hours", to: "hours#main"
  patch "hours", to: "hours#update_hours", as: :update_hours
  get "hours/main"
  # get "hours/new"
  get "hours/create"
  # get "sessions/destroy"

  # Following allows controller redirects
  get  "newlogin",  to: "hours#newlogin"
  post "newlogin",  to: "hours#createlogin"
  post "changepassword", to: "hours#changepassword"
  delete "logout", to: "hours#destroy"

  # products routes
  get "products", to: "products#index"
  get "products/index"
  get "products/show"
  get "products/new"
  post "products/create", as: :products_create
  get "products/edit", as: :products_edit
  patch "products/update", as: :products_update
  delete "products/destroy", as: :products_destroy
  # Events controller routes
  get "events", to: "events#events"
  get "events/image", to: "events#image", as: :events_image
end
