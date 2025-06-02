class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard]

  def home
    # por crear
  end

  def dashboard
    @recommended_movies = []
    @recommendation_reasoning = "Aún no tenemos suficientes datos para generar recomendaciones. ¡Explora y marca tus películas!"
    @pagy_recommendations = nil # Inicializa para evitar errores si no hay recomendaciones

    liked_movies = current_user.favorite_movies.includes(:genres, :director)
    source_movies_for_prefs = liked_movies 

    if source_movies_for_prefs.any?
      interacted_movie_ids = (current_user.favorite_movie_ids +
                              current_user.watched_movie_ids +
                              current_user.watchlist_movie_ids).uniq

      # Géneros preferidos
      genre_counts = source_movies_for_prefs.flat_map(&:genres).group_by(&:id).transform_values(&:count)
      preferred_genre_ids = genre_counts.sort_by { |_id, count| -count }.first(2).map(&:first)

      # Directores preferidos
      director_counts = source_movies_for_prefs.map(&:director_id).compact.group_by(&:itself).transform_values(&:count)
      preferred_director_ids = director_counts.sort_by { |_id, count| -count }.first(2).map(&:first)

      # Décadas preferidas
      release_years = source_movies_for_prefs.map(&:release_year).compact
      decade_counts = release_years.map { |y| (y / 10) * 10 }.group_by(&:itself).transform_values(&:count)
      preferred_decades = decade_counts.sort_by { |_decade, count| -count }.first(2).map(&:first)

      candidate_movies_query = Movie.where.not(id: interacted_movie_ids)
                                      .where.not(weighted_score: nil)
                                      .includes(:genres, :director)
      
      scored_candidates = []
      candidate_movies_query.find_each do |candidate| 
        score = 0
        candidate.genre_ids.each do |genre_id| 
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
      
      sorted_recommendations = scored_candidates.sort_by { |s| [-s[:recommendation_score], -s[:weighted_score]] } #
      
      final_recommended_movies = sorted_recommendations.map { |s| s[:movie] } 

      if final_recommended_movies.any?
        @pagy_recommendations, @recommended_movies = pagy_array(final_recommended_movies, items: 10, page_param: :recs_page)
        @recommendation_reasoning = "Basado en tus gustos por ciertos géneros, directores y épocas."
      else
        @recommendation_reasoning = "No encontramos recomendaciones nuevas para ti en este momento. ¡Sigue explorando!"
      end
    end
  end
end