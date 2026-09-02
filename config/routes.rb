Rails.application.routes.draw do
  get "merch", to: "merch#index"
  get "merch/index"
  get "merch/show"
  get "merch/update"
  get "merch/destroy"
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
