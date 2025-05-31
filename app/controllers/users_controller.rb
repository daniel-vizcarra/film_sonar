class UsersController < ApplicationController
  before_action :authenticate_user!

  def my_favorites
    favorite_movies_query = current_user.favorite_movies.order(created_at: :desc)
    @pagy, @favorite_movies = pagy(favorite_movies_query, items: 12)
  end

  # NUEVA ACCIÓN para Películas Vistas
  def watched_movies
    watched_movies_query = current_user.watched_movies.joins(:watched_entries).order('watched_entries.created_at DESC') # Ordenar por cuándo se marcó como vista
    @pagy, @watched_movies = pagy(watched_movies_query, items: 12)
  end

  # NUEVA ACCIÓN para Watchlist
  def watchlist_movies
    watchlist_movies_query = current_user.watchlist_movies.joins(:watchlist_entries).order('watchlist_entries.created_at DESC') # Ordenar por cuándo se añadió
    @pagy, @watchlist_movies = pagy(watchlist_movies_query, items: 12)
  end
end