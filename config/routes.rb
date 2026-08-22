Rails.application.routes.draw do
  root "pages#home"

  get "events", to: "pages#events"
  get "menu", to: "pages#menu"
  get "press", to: "pages#press"
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
  get "gallery", to: "pages#gallery"

  get "up" => "rails/health#show", as: :rails_health_check
end
