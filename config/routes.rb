# config/routes.rb
Rails.application.routes.draw do
  get "users/my_favorites"
  namespace :movies do
    get "watchlist_entries/create"
    get "watchlist_entries/destroy"
    get "watched_entries/create"
    get "watched_entries/destroy"
    get "favorites/create"
    get "favorites/destroy"
  end
  devise_for :users
  root "pages#home"
  get '/dashboard', to: 'pages#dashboard', as: 'dashboard'

  # Rutas para el catálogo de películas de usuarios
  resources :movies, only: [:index, :show] do
    resource :favorite, only: [:create, :destroy], module: :movies
    resource :watched_entry, only: [:create, :destroy], module: :movies # Para marcar/desmarcar como vista
    resource :watchlist_entry, only: [:create, :destroy], module: :movies # Para añadir/quitar de la watchlist
  end

  get '/my_favorites', to: 'users#my_favorites', as: 'my_favorites'


  namespace :admin do
    get "directors/index"
    get "directors/show"
    get "directors/new"
    get "directors/create"
    get "directors/edit"
    get "directors/update"
    get "directors/destroy"
    resources :movies
    resources :directors
    root to: "movies#index"
  end
  # ... (ruta 'up' al final si está)
  get "up" => "rails/health#show", as: :rails_health_check
end