module FavoritesHelper # o ApplicationHelper
    def current_user_has_favorited?(movie)
      user_signed_in? && current_user.favorite_movies.include?(movie)
    end
  end