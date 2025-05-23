# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  root "pages#home"
  get '/dashboard', to: 'pages#dashboard', as: 'dashboard'

  # Rutas para el catálogo de películas de usuarios
  resources :movies, only: [:index, :show] # <--- AÑADE ESTO

  namespace :admin do
    resources :movies
    root to: "movies#index"
  end
  # ... (ruta 'up' al final si está)
  get "up" => "rails/health#show", as: :rails_health_check
end