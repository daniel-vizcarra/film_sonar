# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base

  protected # O private

  def authorize_manager!
    # Redirige al root si el usuario no está logueado O no es manager
    redirect_to root_path, alert: 'No tienes permiso para acceder a esta sección.' unless user_signed_in? && current_user.role == 'manager'
  end
end