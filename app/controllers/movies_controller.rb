class MoviesController < ApplicationController
  # ... (el contenido que pusimos antes para las acciones index y show)
  # include Pagy::Backend # Asegúrate de que esto esté en ApplicationController, no aquí directamente a menos que sea específico.

  def index
    @genres = Genre.all.order(:name)
    # ... (resto de la lógica de index)
    movies_query = Movie.all # O la lógica de filtrado
    if params[:genre_ids].present? && params[:genre_ids].any?(&:present?)
      selected_genre_ids = params[:genre_ids].reject(&:blank?).map(&:to_i)
      if selected_genre_ids.any?
        movies_query = movies_query.joins(:genres).where(genres: { id: selected_genre_ids }).distinct
        @selected_genres_display = Genre.where(id: selected_genre_ids).pluck(:name).join(', ')
      end
    end
    # ... (lógica de sort_option y order_clause) ...
    sort_option = params[:sort_by].presence || "release_year_desc"
    order_clause = case sort_option
                   when "release_year_desc"
                     { release_year: :desc, title: :asc }
                   when "release_year_asc"
                     { release_year: :asc, title: :asc }
                   when "title_asc"
                     Arel.sql("LOWER(movies.title) asc, movies.release_year desc")
                   when "title_desc"
                     Arel.sql("LOWER(movies.title) desc, movies.release_year desc")
                   when "director_asc"
                     Arel.sql("LOWER(movies.director) asc, movies.title asc")
                   when "director_desc"
                     Arel.sql("LOWER(movies.director) desc, movies.title asc")
                   else
                     { release_year: :desc, title: :asc }
                   end
    movies_query = movies_query.order(order_clause)
    @pagy, @movies = pagy(movies_query, items: 12)
  end

  def show
    @movie = Movie.find(params[:id])
  end
end