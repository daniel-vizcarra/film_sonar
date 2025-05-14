# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  # ... (tus rutas existentes como root, up, dashboard) ...
  root "pages#home"
  get '/dashboard', to: 'pages#dashboard', as: 'dashboard'

  # Namespace para la sección de administración
  namespace :admin do
    resources :movies # Esto crea todas las rutas CRUD para películas bajo /admin/movies
                      # (index, show, new, create, edit, update, destroy)
    root to: "movies#index" # Hace que /admin sea la página principal del listado de películas de admin
  end
end