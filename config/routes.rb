Rails.application.routes.draw do
  root "pages#home"

  get "press", to: "pages#press"
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
  get "gallery", to: "pages#gallery", as: :gallery
  get "galleryimage", to: "pages#galleryimage", as: :gallery_image
  get "up" => "rails/health#show", as: :rails_health_check


  # menu controller main
  get "menu", to: "menu#menu"
  get "menu/image", to: "menu#image", as: :menu_image
  get "menu/new", to: "menu#new", as: :menu_new
  post "menu/new", to: "menu#create", as: :menu_create

  # Events controller routes
  get "events", to: "events#events"
  get "events/image", to: "events#image", as: :events_image

  # Hours controller routes
  get "hours", to: "hours#main", as: :hours
  patch "hours", to: "hours#update_hours", as: :update_hours
  get "hours/main"
  get "hours/create"

  # Change controller routes
  get "change", to: "change#newlogin"
  post "change/newlogin", to: "change#createlogin"

  # Following allows controller redirects
  get  "newlogin",  to: "change#newlogin"
  post "newlogin",  to: "change#createlogin"
  post "changepassword", to: "change#changepassword"
  delete "logout", to: "change#destroy"
  end


# # products routes these are currently disabled as the products feature is not currently used
# get "products", to: "products#index"
# get "products/index"
# get "products/show"
# get "products/new"
# post "products/create", as: :products_create
# get "products/edit", as: :products_edit
# patch "products/update", as: :products_update
# delete "products/destroy", as: :products_destroy
