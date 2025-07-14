# app/models/concerns/recommendation_strategy.rb
module RecommendationStrategy
  extend ActiveSupport::Concern

  # Interface base para estrategias de recomendación
  # Aplica el principio Open/Closed: abierto para extensión, cerrado para modificación
  
  def recommend(user_preferences, candidate_movies)
    raise NotImplementedError, "#{self.class} debe implementar el método recommend"
  end

  def calculate_score(movie, preferences)
    raise NotImplementedError, "#{self.class} debe implementar el método calculate_score"
  end

  def strategy_name
    self.class.name.demodulize.underscore
  end
end 