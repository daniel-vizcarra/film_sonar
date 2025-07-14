class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard]

  def home
    # por crear
  end

  def dashboard
    # Aplica el principio Single Responsibility: solo maneja la presentación
    # Aplica el principio Dependency Inversion: depende del servicio de recomendaciones
    recommendation_service = RecommendationService.new(current_user)
    
    @recommended_movies = recommendation_service.generate_recommendations(limit: 10)
    @recommendation_reasoning = recommendation_service.get_recommendation_reasoning
    
    if @recommended_movies.any?
      @pagy_recommendations, @recommended_movies = pagy_array(@recommended_movies, items: 10, page_param: :recs_page)
    else
      @pagy_recommendations = nil
    end
  end
end