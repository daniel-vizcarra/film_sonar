class Movies::FavoritesController < ApplicationController
  before_action :authenticate_user! 
  before_action :set_movie         

  # POST /movies/:movie_id/favorite
  def create
    # Verificamos si el usuario ya tiene esta película como favorita
    if current_user.favorite_movies.include?(@movie)

      redirect_back fallback_location: movie_path(@movie), 
                    alert: 'Esta película ya está en tus favoritos.'
    else

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

  def set_movie
    @movie = Movie.find(params[:movie_id])
  end
end