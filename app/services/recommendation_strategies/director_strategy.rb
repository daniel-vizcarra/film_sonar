# app/services/recommendation_strategies/director_strategy.rb
class RecommendationStrategies::DirectorStrategy
  include RecommendationStrategy

  # Estrategia de recomendación basada en preferencias de directores
  # Aplica el principio Single Responsibility: solo se encarga de recomendaciones por director

  def recommend(user_preferences, candidate_movies)
    return [] if user_preferences[:preferred_director_ids].blank?

    scored_movies = candidate_movies.map do |movie|
      score = calculate_score(movie, user_preferences)
      { movie: movie, score: score, reason: "Basado en tu preferencia por el director" } if score > 0
    end.compact

    scored_movies.sort_by { |item| -item[:score] }
  end

  def calculate_score(movie, preferences)
    return 0 if preferences[:preferred_director_ids].blank?

    # Calcular puntuación basada en directores preferidos
    director_score = 0
    if movie.director_id && preferences[:preferred_director_ids].include?(movie.director_id)
      director_score += 3 # Peso muy alto para directores preferidos
    end

    # Bonus por weighted_score de la película
    weighted_bonus = (movie.weighted_score || 0) * 0.1

    director_score + weighted_bonus
  end

  private

  def strategy_name
    'director_based'
  end
end 