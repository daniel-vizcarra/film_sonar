# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard]

  def home
    # Tu lógica actual para la página de inicio
  end

  def dashboard
    @recommended_movies = []
    @recommendation_reasoning = "Aún no tenemos suficientes datos para generar recomendaciones. ¡Explora y marca tus películas!"
    @pagy_recommendations = nil # Inicializa para evitar errores si no hay recomendaciones

    liked_movies = current_user.favorite_movies.includes(:genres, :director)
    source_movies_for_prefs = liked_movies # Simplificado a solo 'liked' por ahora

    if source_movies_for_prefs.any?
      interacted_movie_ids = (current_user.favorite_movie_ids +
                              current_user.watched_movie_ids +
                              current_user.watchlist_movie_ids).uniq

      # Géneros preferidos
      genre_counts = source_movies_for_prefs.flat_map(&:genres).group_by(&:id).transform_values(&:count)
      # Corregido: usa 'id_genre' o simplemente '_' si no usas la clave para ordenar
      preferred_genre_ids = genre_counts.sort_by { |_id, count| -count }.first(2).map(&:first)

      # Directores preferidos
      director_counts = source_movies_for_prefs.map(&:director_id).compact.group_by(&:itself).transform_values(&:count)
      # Corregido: usa 'id_director' o '_'
      preferred_director_ids = director_counts.sort_by { |_id, count| -count }.first(2).map(&:first)

      # Décadas preferidas
      release_years = source_movies_for_prefs.map(&:release_year).compact
      decade_counts = release_years.map { |y| (y / 10) * 10 }.group_by(&:itself).transform_values(&:count)
      # Corregido: usa 'decade_key' o '_'
      preferred_decades = decade_counts.sort_by { |_decade, count| -count }.first(2).map(&:first)

      candidate_movies_query = Movie.where.not(id: interacted_movie_ids)
                                      .where.not(weighted_score: nil)
                                      .includes(:genres, :director)
      
      scored_candidates = []
      candidate_movies_query.find_each do |candidate| # 'do' está bien aquí para find_each
        score = 0
        candidate.genre_ids.each do |genre_id| # 'do' está bien aquí para each
          score += 2 if preferred_genre_ids.include?(genre_id)
        end
        score += 3 if preferred_director_ids.include?(candidate.director_id)
        if candidate.release_year.present? && preferred_decades.include?((candidate.release_year / 10) * 10)
          score += 1
        end

        if score > 0
          scored_candidates << { movie: candidate, recommendation_score: score, weighted_score: candidate.weighted_score || 0 }
        end
      end
      
      sorted_recommendations = scored_candidates.sort_by { |s| [-s[:recommendation_score], -s[:weighted_score]] } # El bloque aquí está bien
      
      final_recommended_movies = sorted_recommendations.map { |s| s[:movie] } # El bloque aquí está bien

      if final_recommended_movies.any?
        @pagy_recommendations, @recommended_movies = pagy_array(final_recommended_movies, items: 10, page_param: :recs_page)
        @recommendation_reasoning = "Basado en tus gustos por ciertos géneros, directores y épocas."
      else
        # Mantener mensaje si, después de la lógica, no hay recomendaciones finales
        @recommendation_reasoning = "No encontramos recomendaciones nuevas para ti en este momento. ¡Sigue explorando!"
      end
    end
  end
end