# app/helpers/movie_actions_helper.rb
module MovieActionsHelper
    def current_user_has_liked?(movie)
      # Devuelve false si no hay usuario logueado o la película es nil
      return false unless user_signed_in? && movie.present?
      # Verifica si la película está entre las favoritas del usuario actual
      current_user.favorite_movies.exists?(movie.id)
    end
  
    def current_user_has_watched?(movie)
      return false unless user_signed_in? && movie.present?
      current_user.watched_movies.exists?(movie.id)
    end
  
    def current_user_is_in_watchlist?(movie)
      return false unless user_signed_in? && movie.present?
      current_user.watchlist_movies.exists?(movie.id)
    end
  end