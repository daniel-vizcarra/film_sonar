# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < BaseController
      before_action :authenticate_user!

      # GET /api/v1/users/profile
      def profile
        render_success({
          user: user_serializer(current_user)
        })
      end

      # GET /api/v1/users/favorites
      def favorites
        favorites = current_user.favorite_movies.includes(:genres, :director)
        
        render_success({
          movies: favorites.map { |movie| movie_serializer(movie) },
          total_count: favorites.count
        })
      end

      # GET /api/v1/users/watched
      def watched
        watched_movies = current_user.watched_movies.includes(:genres, :director)
        
        render_success({
          movies: watched_movies.map { |movie| movie_serializer(movie) },
          total_count: watched_movies.count
        })
      end

      # GET /api/v1/users/watchlist
      def watchlist
        watchlist_movies = current_user.watchlist_movies.includes(:genres, :director)
        
        render_success({
          movies: watchlist_movies.map { |movie| movie_serializer(movie) },
          total_count: watchlist_movies.count
        })
      end

      private

      def user_serializer(user)
        {
          id: user.id,
          email: user.email,
          role: user.role,
          created_at: user.created_at,
          stats: {
            total_favorites: user.favorites.count,
            total_watched: user.watched_entries.count,
            total_watchlist: user.watchlist_entries.count
          }
        }
      end

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