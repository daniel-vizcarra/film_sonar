# app/controllers/api/v1/movies_controller.rb
module Api
  module V1
    class MoviesController < BaseController
      before_action :set_movie_repository, only: [:index, :show, :similar, :top]

      # GET /api/v1/movies
      def index
        filters = build_filters_from_params
        movies = @movie_repository.find_by_filters(filters)
        
        # Aplicar ordenamiento
        movies = apply_sorting(movies)
        
        # Paginación
        page = params[:page] || 1
        per_page = [params[:per_page] || 20, 100].min # Máximo 100 por página
        
        total_count = movies.count
        total_pages = (total_count.to_f / per_page).ceil
        
        movies = movies.offset((page.to_i - 1) * per_page).limit(per_page)
        
        render_success({
          movies: movies.map { |movie| movie_serializer(movie) },
          pagination: {
            current_page: page.to_i,
            total_pages: total_pages,
            total_count: total_count,
            per_page: per_page
          }
        })
      end

      # GET /api/v1/movies/:id
      def show
        movie = @movie_repository.find_by_id(params[:id])
        render_success({
          movie: movie_serializer(movie, detailed: true)
        })
      end

      # GET /api/v1/movies/:id/similar
      def similar
        movie = @movie_repository.find_by_id(params[:id])
        similar_movies = @movie_repository.find_similar(movie, limit: params[:limit] || 6)
        
        render_success({
          movie: movie_serializer(movie),
          similar_movies: similar_movies.map { |movie| movie_serializer(movie) }
        })
      end

      # GET /api/v1/movies/top
      def top
        limit = [params[:limit] || 10, 50].min # Máximo 50 películas
        top_movies = @movie_repository.find_top_movies(limit: limit)
        
        render_success({
          movies: top_movies.map { |movie| movie_serializer(movie) }
        })
      end

      private

      def set_movie_repository
        @movie_repository = MovieRepository.new
      end

      def build_filters_from_params
        filters = {}
        
        filters[:genre_ids] = params[:genre_ids]&.map(&:to_i) if params[:genre_ids].present?
        filters[:director_ids] = params[:director_ids]&.map(&:to_i) if params[:director_ids].present?
        filters[:year_from] = params[:year_from]&.to_i if params[:year_from].present?
        filters[:year_to] = params[:year_to]&.to_i if params[:year_to].present?
        filters[:min_score] = params[:min_score]&.to_f if params[:min_score].present?
        
        filters
      end

      def apply_sorting(movies)
        sort_by = params[:sort_by] || 'release_year_desc'
        
        case sort_by
        when 'release_year_desc'
          movies.order(release_year: :desc, title: :asc)
        when 'release_year_asc'
          movies.order(release_year: :asc, title: :asc)
        when 'title_asc'
          movies.select("movies.*, LOWER(movies.title) as title_lower")
                .order("title_lower ASC, movies.release_year DESC")
        when 'title_desc'
          movies.select("movies.*, LOWER(movies.title) as title_lower")
                .order("title_lower DESC, movies.release_year DESC")
        when 'score_desc'
          movies.order(weighted_score: :desc, title: :asc)
        when 'score_asc'
          movies.order(weighted_score: :asc, title: :asc)
        else
          movies.order(release_year: :desc, title: :asc)
        end
      end

      def movie_serializer(movie, detailed: false)
        data = {
          id: movie.id,
          title: movie.title,
          description: movie.description,
          release_year: movie.release_year,
          poster_url: movie.poster_url,
          weighted_score: movie.weighted_score,
          director: movie.director ? {
            id: movie.director.id,
            name: movie.director.name
          } : nil,
          genres: movie.genres.map { |genre| {
            id: genre.id,
            name: genre.name
          }}
        }

        if detailed
          data[:external_ratings] = movie.external_ratings.map { |rating| {
            source: rating.source_name,
            score: rating.score,
            vote_count: rating.vote_count,
            normalized_score: rating.normalized_score
          }}
        end

        # Agregar interacciones del usuario si está autenticado
        if current_user
          data[:user_interactions] = {
            is_favorite: current_user.favorites.exists?(movie: movie),
            is_watched: current_user.watched_entries.exists?(movie: movie),
            in_watchlist: current_user.watchlist_entries.exists?(movie: movie)
          }
        end

        data
      end
    end
  end
end 