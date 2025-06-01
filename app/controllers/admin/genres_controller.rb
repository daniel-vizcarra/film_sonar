# app/controllers/admin/genres_controller.rb
module Admin
  class GenresController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_manager!
    before_action :set_genre, only: [:show, :edit, :update, :destroy]

    # GET /admin/genres
    def index
      @genres = Genre.all.order(:name)
    end

    # GET /admin/genres/:id (Opcional si no necesitas una página de "show" para admin)
    def show
      # @genre ya está seteado por set_genre
    end

    # GET /admin/genres/new
    def new
      @genre = Genre.new
    end

    # POST /admin/genres
    def create
      @genre = Genre.new(genre_params)
      if @genre.save
        redirect_to admin_genres_path, notice: 'Género creado exitosamente.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    # GET /admin/genres/:id/edit
    def edit
      # @genre ya está seteado por set_genre
    end

    # PATCH/PUT /admin/genres/:id
    def update
      if @genre.update(genre_params)
        redirect_to admin_genres_path, notice: 'Género actualizado exitosamente.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /admin/genres/:id
    def destroy
      # Considerar qué pasa con las películas si un género se elimina.
      # Por defecto, si hay películas asociadas a través de genres_movies,
      # la base de datos podría impedir la eliminación si hay una restricción de FK,
      # o Rails podría fallar.
      # Una opción es eliminar las asociaciones en genres_movies antes de destruir el género,
      # o simplemente no permitir la eliminación si el género está en uso.
      # Por ahora, lo dejamos simple.
      if @genre.movies.empty?
        @genre.destroy
        redirect_to admin_genres_path, notice: 'Género eliminado exitosamente.', status: :see_other
      else
        redirect_to admin_genres_path, alert: 'No se puede eliminar el género porque tiene películas asociadas.', status: :unprocessable_entity
      end
    end

    private

    def set_genre
      @genre = Genre.find(params[:id])
    end

    def genre_params
      params.require(:genre).permit(:name)
    end
  end
end