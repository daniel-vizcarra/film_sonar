# app/controllers/movies_controller.rb
class MoviesController < ApplicationController
  # Aplica el principio Dependency Inversion: depende de abstracciones (Repository)
  def initialize
    super
    @movie_repository = MovieRepository.new
  end

  def index
    # Aplica el principio Single Responsibility: solo maneja la presentación
    setup_filters
    setup_top_movies
    setup_movies_with_filters
    setup_active_filters
    apply_sorting
    paginate_results
  end

  def show
    @movie = @movie_repository.find_by_id(params[:id])
    @similar_movies = @movie_repository.find_similar(@movie)
  end

  private

  def setup_filters
    @genres = Genre.all.order(:name)
    @directors = Director.all.order(:name)
  end

  def setup_top_movies
    @top_10_movies = @movie_repository.find_top_movies(limit: 10)
  end

  def setup_movies_with_filters
    filters = build_filters_from_params
    @movies_query = @movie_repository.find_by_filters(filters)
  end

  def build_filters_from_params
    filters = {}
    
    # Filtrar por géneros
    if params[:genre_ids].present? && params[:genre_ids].any?(&:present?)
      selected_genre_ids = params[:genre_ids].reject(&:blank?).map(&:to_i)
      if selected_genre_ids.any?
        filters[:genre_ids] = selected_genre_ids
        @selected_genres_display = Genre.where(id: selected_genre_ids).pluck(:name).join(', ')
      end
    end

    # Filtrar por directores
    if params[:director_ids].present? && params[:director_ids].any?(&:present?)
      selected_director_ids = params[:director_ids].reject(&:blank?).map(&:to_i)
      if selected_director_ids.any?
        filters[:director_ids] = selected_director_ids
        @selected_directors_display = Director.where(id: selected_director_ids).pluck(:name).join(', ')
      end
    end

    filters
  end

  def setup_active_filters
    active_filters = []
    active_filters << "Géneros: #{@selected_genres_display}" if @selected_genres_display
    active_filters << "Directores: #{@selected_directors_display}" if @selected_directors_display
    @active_filters_message = active_filters.join('; ') if active_filters.any?
  end

  def apply_sorting
    sort_option = params[:sort_by].presence || "release_year_desc"
    
    case sort_option
    when "release_year_desc"
      @movies_query = @movies_query.order(release_year: :desc, title: :asc)
    when "release_year_asc"
      @movies_query = @movies_query.order(release_year: :asc, title: :asc)
    when "title_asc"
      @movies_query = @movies_query.select("movies.*, LOWER(movies.title) as title_lower")
                                  .order("title_lower ASC, movies.release_year DESC")
    when "title_desc"
      @movies_query = @movies_query.select("movies.*, LOWER(movies.title) as title_lower")
                                  .order("title_lower DESC, movies.release_year DESC")
    when "director_asc"
      @movies_query = @movies_query.joins(:director)
                                  .select("movies.*, LOWER(directors.name) as director_name")
                                  .order("director_name ASC, movies.title ASC")
    when "director_desc"
      @movies_query = @movies_query.joins(:director)
                                  .select("movies.*, LOWER(directors.name) as director_name")
                                  .order("director_name DESC, movies.title ASC")
    when "score_desc"
      @movies_query = @movies_query.order(weighted_score: :desc, title: :asc)
    when "score_asc"
      @movies_query = @movies_query.order(weighted_score: :asc, title: :asc)
    else
      @movies_query = @movies_query.order(release_year: :desc, title: :asc)
    end

    @movies_query = @movies_query.distinct
  end

  def paginate_results
    @pagy, @movies = pagy(@movies_query, items: 20)
  end
end