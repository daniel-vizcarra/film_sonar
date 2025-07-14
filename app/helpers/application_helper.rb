# app/helpers/application_helper.rb
module ApplicationHelper
  include Pagy::Frontend
  
  def body_class
    controller_name = controller.controller_name
    action_name = controller.action_name
    
    classes = []
    classes << "#{controller_name}-#{action_name}"
    classes << controller_name
    
    # Clase especial para la página de inicio
    if controller_name == 'pages' && action_name == 'home'
      classes << 'home-page'
    end
    
    classes.join(' ')
  end
end