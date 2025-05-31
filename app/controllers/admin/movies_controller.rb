# app/controllers/admin/movies_controller.rb
module Admin
    class MoviesController < ApplicationController
      before_action :authenticate_user!   # Primero, asegúrate de que el usuario haya iniciado sesión
      before_action :authorize_manager!   # Luego, usa nuestro helper para verificar si es manager
  
      # GET /admin/movies
      def index
        @movies = Movie.all.order(created_at: :desc) # Obtiene todas las películas, ordenadas por más recientes
      end
  
      # GET /admin/movies/:id
      def show
        @movie = Movie.find(params[:id])
      end
  
      # GET /admin/movies/new
      def new
        @movie = Movie.new
        # Preparamos una lista ordenada de external_ratings para el formulario
        @ordered_external_ratings = ExternalRating::SOURCES.map do |source_name|
          # Construimos un nuevo objeto ExternalRating para cada fuente
          @movie.external_ratings.build(source_name: source_name)
        end
      end
  
      # POST /admin/movies
      def create
        @movie = Movie.new(movie_params)
        if @movie.save
          redirect_to admin_movie_path(@movie), notice: 'Película creada exitosamente.'
        else
          render :new, status: :unprocessable_entity
        end
      end
  
      # GET /admin/movies/:id/edit
      def edit
        @movie = Movie.find(params[:id])
      
        # Obtenemos los ratings existentes y los mapeamos por nombre de fuente para fácil acceso
        existing_ratings_by_source = @movie.external_ratings.index_by(&:source_name)
      
        # Preparamos una lista ordenada de external_ratings para el formulario
        # Para cada fuente en ExternalRating::SOURCES, usamos el rating existente si hay,
        # o construimos uno nuevo si no existe.
        @ordered_external_ratings = ExternalRating::SOURCES.map do |source_name|
          existing_ratings_by_source[source_name] || @movie.external_ratings.build(source_name: source_name)
        end
      end
  
      # PATCH/PUT /admin/movies/:id
      def update
        @movie = Movie.find(params[:id])
        if @movie.update(movie_params)
          redirect_to admin_movie_path(@movie), notice: 'Película actualizada exitosamente.'
        else
          render :edit, status: :unprocessable_entity
        end
      end
  
      # DELETE /admin/movies/:id
      def destroy
        @movie = Movie.find(params[:id])
        @movie.destroy
        redirect_to admin_movies_path, notice: 'Película eliminada exitosamente.', status: :see_other
      end
  
      private
  
      # Strong Parameters: solo permite los atributos que queremos para la creación/actualización
      def movie_params
        params.require(:movie).permit(
          :title,
          :description,
          :release_year,
          :director_id,
          :poster_url,
          genre_ids: [], # Importante para permitir la asignación de múltiples géneros
          external_ratings_attributes: [:id, :source_name, :score, :vote_count, :_destroy] 

        )
      end
    end
  end