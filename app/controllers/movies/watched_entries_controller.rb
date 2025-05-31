class Movies::WatchedEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie

  def create
    # Si ya está marcada como vista, quizás no hacer nada o un mensaje
    unless current_user.watched_movies.include?(@movie)
      current_user.watched_entries.create!(movie: @movie, watched_on: Date.current) # Opcional: watched_on
      redirect_back fallback_location: movie_path(@movie), notice: 'Marcada como vista!'
    else
      redirect_back fallback_location: movie_path(@movie), alert: 'Ya has marcado esta película como vista.'
    end
  end

  def destroy
    entry = current_user.watched_entries.find_by(movie_id: @movie.id)
    if entry
      entry.destroy
      redirect_back fallback_location: movie_path(@movie), notice: 'Quitada de tu lista de vistas.', status: :see_other
    else
      redirect_back fallback_location: movie_path(@movie), alert: 'Esta película no estaba en tu lista de vistas.'
    end
  end

  private
  def set_movie
    @movie = Movie.find(params[:movie_id])
  end
end