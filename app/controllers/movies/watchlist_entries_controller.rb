class Movies::WatchlistEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie

  def create
    unless current_user.watchlist_movies.include?(@movie)
      current_user.watchlist_entries.create!(movie: @movie)
      redirect_back fallback_location: movie_path(@movie), notice: 'Añadida a tu Watchlist!'
    else
      redirect_back fallback_location: movie_path(@movie), alert: 'Esta película ya está en tu Watchlist.'
    end
  end

  def destroy
    entry = current_user.watchlist_entries.find_by(movie_id: @movie.id)
    if entry
      entry.destroy
      redirect_back fallback_location: movie_path(@movie), notice: 'Quitada de tu Watchlist.', status: :see_other
    else
      redirect_back fallback_location: movie_path(@movie), alert: 'Esta película no estaba en tu Watchlist.'
    end
  end

  private
  def set_movie
    @movie = Movie.find(params[:movie_id])
  end
end