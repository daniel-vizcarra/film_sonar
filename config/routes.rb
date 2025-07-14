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
  get '/my_watched_movies', to: 'users#watched_movies', as: 'my_watched_movies' 
  get '/my_watchlist', to: 'users#watchlist_movies', as: 'my_watchlist'       


  namespace :admin do
    get "genres/index"
    get "genres/show"
    get "genres/new"
    get "genres/create"
    get "genres/edit"
    get "genres/update"
    get "genres/destroy"
    get "directors/index"
    get "directors/show"
    get "directors/new"
    get "directors/create"
    get "directors/edit"
    get "directors/update"
    get "directors/destroy"
    resources :movies
    resources :directors
    resources :genres
    root to: "movies#index"
  end
  get "up" => "rails/health#show", as: :rails_health_check

  # API Routes
  namespace :api do
    namespace :v1 do
      # Películas
      resources :movies, only: [:index, :show] do
        collection do
          get :top
        end
        member do
          get :similar
        end
      end

      # Recomendaciones
      get 'recommendations', to: 'recommendations#index'
      get 'recommendations/explore', to: 'recommendations#explore'

      # Acciones de usuario (requieren autenticación)
      resources :movies, only: [] do
        member do
          post :favorite, to: 'user_actions#favorite'
          delete :favorite, to: 'user_actions#unfavorite'
          post :watched, to: 'user_actions#watched'
          delete :watched, to: 'user_actions#unwatched'
          post :watchlist, to: 'user_actions#watchlist'
          delete :watchlist, to: 'user_actions#unwatchlist'
        end
      end

      # Usuarios
      get 'users/profile', to: 'users#profile'
      get 'users/favorites', to: 'users#favorites'
      get 'users/watched', to: 'users#watched'
      get 'users/watchlist', to: 'users#watchlist'
    end
  end
end