# app/controllers/api/v1/user_actions_controller.rb
module Api
  module V1
    class UserActionsController < BaseController
      before_action :authenticate_user!
      before_action :set_movie, only: [:favorite, :watched, :watchlist]

      # POST /api/v1/movies/:id/favorite
      def favorite
        if current_user.favorites.exists?(movie: @movie)
          render_error('La película ya está en favoritos', :unprocessable_entity)
        else
          current_user.favorites.create!(movie: @movie)
          render_success({ 
            movie_id: @movie.id,
            is_favorite: true 
          }, 'Película agregada a favoritos')
        end
      end

      # DELETE /api/v1/movies/:id/favorite
      def unfavorite
        favorite = current_user.favorites.find_by(movie: @movie)
        if favorite
          favorite.destroy
          render_success({ 
            movie_id: @movie.id,
            is_favorite: false 
          }, 'Película removida de favoritos')
        else
          render_error('La película no está en favoritos', :not_found)
        end
      end

      # POST /api/v1/movies/:id/watched
      def watched
        if current_user.watched_entries.exists?(movie: @movie)
          render_error('La película ya está marcada como vista', :unprocessable_entity)
        else
          current_user.watched_entries.create!(movie: @movie)
          render_success({ 
            movie_id: @movie.id,
            is_watched: true 
          }, 'Película marcada como vista')
        end
      end

      # DELETE /api/v1/movies/:id/watched
      def unwatched
        watched_entry = current_user.watched_entries.find_by(movie: @movie)
        if watched_entry
          watched_entry.destroy
          render_success({ 
            movie_id: @movie.id,
            is_watched: false 
          }, 'Película removida de vistas')
        else
          render_error('La película no está marcada como vista', :not_found)
        end
      end

      # POST /api/v1/movies/:id/watchlist
      def watchlist
        if current_user.watchlist_entries.exists?(movie: @movie)
          render_error('La película ya está en la watchlist', :unprocessable_entity)
        else
          current_user.watchlist_entries.create!(movie: @movie)
          render_success({ 
            movie_id: @movie.id,
            in_watchlist: true 
          }, 'Película agregada a la watchlist')
        end
      end

      # DELETE /api/v1/movies/:id/watchlist
      def unwatchlist
        watchlist_entry = current_user.watchlist_entries.find_by(movie: @movie)
        if watchlist_entry
          watchlist_entry.destroy
          render_success({ 
            movie_id: @movie.id,
            in_watchlist: false 
          }, 'Película removida de la watchlist')
        else
          render_error('La película no está en la watchlist', :not_found)
        end
      end

      private

      def set_movie
        @movie = Movie.find(params[:id])
      end
    end
  end
end 