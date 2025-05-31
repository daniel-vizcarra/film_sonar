# app/controllers/movies/favorites_controller.rb
class Movies::FavoritesController < ApplicationController
  before_action :authenticate_user! # Asegura que el usuario haya iniciado sesión
  before_action :set_movie          # Carga la película basada en params[:movie_id]

  # POST /movies/:movie_id/favorite
  def create
    # Verificamos si el usuario ya tiene esta película como favorita
    if current_user.favorite_movies.include?(@movie)
      # Si ya es favorita, redirigimos de vuelta con una alerta.
      # 'redirect_back' intenta ir a la página anterior.
      # 'fallback_location' se usa si no se puede determinar la página anterior.
      redirect_back fallback_location: movie_path(@movie), 
                    alert: 'Esta película ya está en tus favoritos.'
    else
      # Si no es favorita, la añadimos a los favoritos del usuario.
      # El 'create!' fallará ruidosamente si hay un error (ej. validación del modelo Favorite).
      current_user.favorites.create!(movie: @movie)
      redirect_back fallback_location: movie_path(@movie), 
                    notice: 'Película añadida a favoritos!'
    end
  end

  # DELETE /movies/:movie_id/favorite
  def destroy
    # Buscamos el registro 'Favorite' específico para este usuario y esta película.
    favorite = current_user.favorites.find_by(movie_id: @movie.id)

    if favorite
      favorite.destroy # Eliminamos el registro de favorito.
      redirect_back fallback_location: movie_path(@movie), 
                    notice: 'Película eliminada de favoritos.', 
                    status: :see_other # status: :see_other es una buena práctica para respuestas DELETE con Turbo.
    else
      # Si por alguna razón no se encontró el registro de favorito.
      redirect_back fallback_location: movie_path(@movie), 
                    alert: 'Esta película no estaba en tus favoritos.'
    end
  end

  private

  # Método privado para cargar el objeto @movie
  def set_movie
    @movie = Movie.find(params[:movie_id])
  end
end