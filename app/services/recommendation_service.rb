# app/services/recommendation_service.rb
class RecommendationService
  # Servicio de recomendaciones que coordina diferentes estrategias
  # Aplica el principio Dependency Inversion: depende de abstracciones, no de implementaciones concretas

  def initialize(user)
    @user = user
    @strategies = [
      RecommendationStrategies::GenreStrategy.new,
      RecommendationStrategies::DirectorStrategy.new
    ]
  end

  def generate_recommendations(limit: 10)
    return [] unless @user.present?

    user_preferences = extract_user_preferences
    candidate_movies = find_candidate_movies(user_preferences)
    
    return [] if candidate_movies.empty?

    # Aplicar todas las estrategias y combinar resultados
    all_recommendations = @strategies.flat_map do |strategy|
      strategy.recommend(user_preferences, candidate_movies)
    end

    # Agrupar por película y sumar puntuaciones
    grouped_recommendations = group_and_score_recommendations(all_recommendations)
    
    # Ordenar y limitar resultados
    grouped_recommendations
      .sort_by { |item| -item[:total_score] }
      .first(limit)
      .map { |item| item[:movie] }
  end

  def get_recommendation_reasoning
    return "Aún no tenemos suficientes datos para generar recomendaciones. ¡Explora y marca tus películas!" unless @user.present?

    preferences = extract_user_preferences
    reasons = []

    reasons << "Basado en tus gustos por ciertos géneros" if preferences[:preferred_genre_ids].any?
    reasons << "Basado en tus directores favoritos" if preferences[:preferred_director_ids].any?

    reasons.any? ? reasons.join(" y ") : "Basado en tus preferencias generales"
  end

  private

  def extract_user_preferences
    liked_movies = @user.favorite_movies.includes(:genres, :director)
    
    # Géneros preferidos
    genre_counts = liked_movies.flat_map(&:genres).group_by(&:id).transform_values(&:count)
    preferred_genre_ids = genre_counts.sort_by { |_id, count| -count }.first(2).map(&:first)

    # Directores preferidos
    director_counts = liked_movies.map(&:director_id).compact.group_by(&:itself).transform_values(&:count)
    preferred_director_ids = director_counts.sort_by { |_id, count| -count }.first(2).map(&:first)

    {
      preferred_genre_ids: preferred_genre_ids,
      preferred_director_ids: preferred_director_ids
    }
  end

  def find_candidate_movies(preferences)
    interacted_movie_ids = (
      @user.favorite_movie_ids +
      @user.watched_movie_ids +
      @user.watchlist_movie_ids
    ).uniq

    Movie.where.not(id: interacted_movie_ids)
         .where.not(weighted_score: nil)
         .includes(:genres, :director)
  end

  def group_and_score_recommendations(recommendations)
    grouped = {}
    
    recommendations.each do |rec|
      movie_id = rec[:movie].id
      
      if grouped[movie_id]
        grouped[movie_id][:total_score] += rec[:score]
        grouped[movie_id][:reasons] << rec[:reason]
      else
        grouped[movie_id] = {
          movie: rec[:movie],
          total_score: rec[:score],
          reasons: [rec[:reason]]
        }
      end
    end

    grouped.values
  end
end 