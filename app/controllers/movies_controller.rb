# app/controllers/movies_controller.rb
class MoviesController < ApplicationController
  # Opcional: Si quieres que solo usuarios logueados vean el catálogo, descomenta:
  # before_action :authenticate_user!

  def index
    @movies = Movie.all.order(release_year: :desc, title: :asc) # Ordena por año (desc) y luego título (asc)
  end

  def show
    @movie = Movie.find(params[:id])
  end
end