# app/controllers/movies_controller.rb
class MoviesController < ApplicationController
  def index
    # Para mostrar los filtros en la vista
    @genres = Genre.all.order(:name)
    @directors = Director.all.order(:name)

    movies_query = Movie.all

    # Filtrar por Géneros seleccionados
    if params[:genre_ids].present? && params[:genre_ids].any?(&:present?)
      selected_genre_ids = params[:genre_ids].reject(&:blank?).map(&:to_i)
      if selected_genre_ids.any?
        movies_query = movies_query.joins(:genres).where(genres: { id: selected_genre_ids })
        @selected_genres_display = Genre.where(id: selected_genre_ids).pluck(:name).join(', ')
      end
    end

    # Filtrar por Directores seleccionados
    if params[:director_ids].present? && params[:director_ids].any?(&:present?)
      selected_director_ids = params[:director_ids].reject(&:blank?).map(&:to_i)
      if selected_director_ids.any?
        movies_query = movies_query.where(director_id: selected_director_ids)
        @selected_directors_display = Director.where(id: selected_director_ids).pluck(:name).join(', ')
      end
    end

    # Para mostrar los filtros activos en la vista
    active_filters = []
    active_filters << "Géneros: #{@selected_genres_display}" if @selected_genres_display
    active_filters << "Directores: #{@selected_directors_display}" if @selected_directors_display
    @active_filters_message = active_filters.join('; ') if active_filters.any?

    # Aplicar Ordenamiento
    sort_option = params[:sort_by].presence || "release_year_desc"
    
    # Modificamos la lógica de ordenamiento para manejar correctamente DISTINCT
    case sort_option
    when "release_year_desc"
      movies_query = movies_query.order(release_year: :desc, title: :asc)
    when "release_year_asc"
      movies_query = movies_query.order(release_year: :asc, title: :asc)
    when "title_asc"
      movies_query = movies_query.select("movies.*, LOWER(movies.title) as title_lower")
                                .order("title_lower ASC, movies.release_year DESC")
    when "title_desc"
      movies_query = movies_query.select("movies.*, LOWER(movies.title) as title_lower")
                                .order("title_lower DESC, movies.release_year DESC")
    when "director_asc"
      movies_query = movies_query.joins(:director)
                                .select("movies.*, LOWER(directors.name) as director_name")
                                .order("director_name ASC, movies.title ASC")
    when "director_desc"
      movies_query = movies_query.joins(:director)
                                .select("movies.*, LOWER(directors.name) as director_name")
                                .order("director_name DESC, movies.title ASC")
    else
      movies_query = movies_query.order(release_year: :desc, title: :asc)
    end

    # Aplicamos DISTINCT después del ordenamiento
    movies_query = movies_query.distinct

    @pagy, @movies = pagy(movies_query, items: 12)
  end

  def show
    @movie = Movie.find(params[:id])
  end
end