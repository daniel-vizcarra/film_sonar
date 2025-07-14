# app/controllers/api/v1/recommendations_controller.rb
module Api
  module V1
    class RecommendationsController < BaseController
      before_action :authenticate_user!

      # GET /api/v1/recommendations
      def index
        recommendation_service = RecommendationService.new(current_user)
        recommendations = recommendation_service.generate_recommendations(limit: params[:limit] || 10)
        reasoning = recommendation_service.get_recommendation_reasoning

        render_success({
          recommendations: recommendations.map { |movie| movie_serializer(movie) },
          reasoning: reasoning,
          total_count: recommendations.count
        })
      end

      # GET /api/v1/recommendations/explore
      def explore
        # Recomendaciones de exploración (películas populares que el usuario no ha visto)
        interacted_movie_ids = (
          current_user.favorite_movie_ids +
          current_user.watched_movie_ids +
          current_user.watchlist_movie_ids
        ).uniq

        explore_movies = Movie.where.not(id: interacted_movie_ids)
                             .where.not(weighted_score: nil)
                             .order(weighted_score: :desc)
                             .limit(params[:limit] || 10)
                             .includes(:genres, :director)

        render_success({
          movies: explore_movies.map { |movie| movie_serializer(movie) },
          reasoning: "Películas populares que podrían interesarte",
          total_count: explore_movies.count
        })
      end

      private

      def movie_serializer(movie)
        {
          id: movie.id,
          title: movie.title,
          description: movie.description,
          release_year: movie.release_year,
          poster_url: movie.poster_url,
          weighted_score: movie.weighted_score,
          director: movie.director ? {
            id: movie.director.id,
            name: movie.director.name
          } : nil,
          genres: movie.genres.map { |genre| {
            id: genre.id,
            name: genre.name
          }},
          user_interactions: {
            is_favorite: current_user.favorites.exists?(movie: movie),
            is_watched: current_user.watched_entries.exists?(movie: movie),
            in_watchlist: current_user.watchlist_entries.exists?(movie: movie)
          }
        }
      end
    end
  end
end 