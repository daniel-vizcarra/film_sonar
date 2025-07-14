# app/services/recommendation_strategies/genre_strategy.rb
class RecommendationStrategies::GenreStrategy
  include RecommendationStrategy

  # Estrategia de recomendación basada en preferencias de géneros
  # Aplica el principio Single Responsibility: solo se encarga de recomendaciones por género

  def recommend(user_preferences, candidate_movies)
    return [] if user_preferences[:preferred_genre_ids].blank?

    scored_movies = candidate_movies.map do |movie|
      score = calculate_score(movie, user_preferences)
      { movie: movie, score: score, reason: "Basado en tus preferencias de género" } if score > 0
    end.compact

    scored_movies.sort_by { |item| -item[:score] }
  end

  def calculate_score(movie, preferences)
    return 0 if preferences[:preferred_genre_ids].blank?

    # Calcular puntuación basada en géneros preferidos
    genre_score = 0
    movie.genre_ids.each do |genre_id|
      if preferences[:preferred_genre_ids].include?(genre_id)
        genre_score += 2 # Peso alto para géneros preferidos
      end
    end

    # Bonus por weighted_score de la película
    weighted_bonus = (movie.weighted_score || 0) * 0.1

    genre_score + weighted_bonus
  end

  private

  def strategy_name
    'genre_based'
  end
end 