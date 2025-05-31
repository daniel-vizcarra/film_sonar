# app/controllers/admin/directors_controller.rb
module Admin
  class DirectorsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_manager!
    before_action :set_director, only: [:show, :edit, :update, :destroy]

    # GET /admin/directors
    def index
      @directors = Director.all.order(:name)
    end

    # GET /admin/directors/:id
    def show
      # @director ya está seteado por set_director
    end

    # GET /admin/directors/new
    def new
      @director = Director.new
    end

    # POST /admin/directors
    def create
      @director = Director.new(director_params)
      if @director.save
        redirect_to admin_directors_path, notice: 'Director creado exitosamente.' # Redirige al listado
      else
        render :new, status: :unprocessable_entity
      end
    end

    # GET /admin/directors/:id/edit
    def edit
      # @director ya está seteado por set_director
    end

    # PATCH/PUT /admin/directors/:id
    def update
      if @director.update(director_params)
        redirect_to admin_directors_path, notice: 'Director actualizado exitosamente.' # Redirige al listado
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /admin/directors/:id
    def destroy
      @director.destroy
      redirect_to admin_directors_path, notice: 'Director eliminado exitosamente.', status: :see_other
    end

    private

    def set_director
      @director = Director.find(params[:id])
    end

    def director_params
      params.require(:director).permit(:name, :bio, :photo_url)
    end
  end
end