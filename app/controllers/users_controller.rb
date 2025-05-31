# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :authenticate_user! # Solo usuarios logueados pueden ver sus favoritos

  def my_favorites
    # Usamos la asociación :favorite_movies que definimos en el modelo User
    # y la paginamos con Pagy.
    favorite_movies_query = current_user.favorite_movies.order(created_at: :desc) # O cualquier otro orden
    @pagy, @favorite_movies = pagy(favorite_movies_query, items: 12) 
  end
end