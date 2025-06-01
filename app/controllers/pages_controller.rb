# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard] # Asegura que solo usuarios logueados accedan

  def home
    # Tu lógica actual para la página de inicio
  end

  def dashboard
    @recommended_movies = [] # Inicializa por si no hay recomendaciones

    # Obtener películas favoritas del usuario actual, incluyendo sus géneros para evitar N+1 queries
    liked_movies = current_user.favorite_movies.includes(:genres)

    if liked_movies.any?
      # Contar la frecuencia de cada género en las películas favoritas
      genre_counts = liked_movies.flat_map(&:genres).group_by(&:id).transform_values(&:count)

      # Ordenar los géneros por frecuencia y tomar los IDs de los (hasta) 2 más frecuentes
      top_genre_ids = genre_counts.sort_by { |_id, count| -count }.first(2).map(&:first)

      if top_genre_ids.any?
        # IDs de películas con las que el usuario ya interactuó (favoritas, vistas, watchlist)
        interacted_movie_ids = (current_user.favorite_movie_ids +
                                current_user.watched_movie_ids +
                                current_user.watchlist_movie_ids).uniq

        # Construir la consulta para recomendaciones
        recommendations_query = Movie.joins(:genres) # Necesario para filtrar por genres.id
                                    .where(genres: { id: top_genre_ids }) # Películas en los géneros top
                                    .where.not(weighted_score: nil)      # Solo películas con puntaje
                                    .distinct                            # Evitar duplicados si una película está en ambos géneros top
                                    .order(weighted_score: :desc)        # Ordenar por mejor puntaje

        # Excluir películas con las que ya interactuó, si hay alguna
        recommendations_query = recommendations_query.where.not(id: interacted_movie_ids) if interacted_movie_ids.any?

        # Paginamos las recomendaciones
        @pagy_recommendations, @recommended_movies = pagy(recommendations_query, items: 10, page_param: :recs_page) # 10 recomendaciones por página
      end
    end
  end
end