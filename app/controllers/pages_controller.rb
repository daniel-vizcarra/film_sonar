# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  # Esta línea ejecuta el filtro de Devise ANTES de la acción :dashboard
  before_action :authenticate_user!, only: [:dashboard]

  def home
  end

  def dashboard
    # Esta acción ahora está protegida por el before_action
  end
end