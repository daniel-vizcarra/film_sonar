# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      # Deshabilitar CSRF para API
      skip_before_action :verify_authenticity_token
      
      # Configurar para responder JSON
      respond_to :json
      
      # Manejo de errores
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
      rescue_from ActionController::ParameterMissing, with: :bad_request
      
      private
      
      def authenticate_user!
        unless current_user
          render json: { 
            status: 'error', 
            message: 'Token de autenticación requerido' 
          }, status: :unauthorized
        end
      end
      
      def not_found(exception)
        render json: { 
          status: 'error', 
          message: 'Recurso no encontrado',
          details: exception.message 
        }, status: :not_found
      end
      
      def unprocessable_entity(exception)
        render json: { 
          status: 'error', 
          message: 'Datos inválidos',
          details: exception.record.errors.full_messages 
        }, status: :unprocessable_entity
      end
      
      def bad_request(exception)
        render json: { 
          status: 'error', 
          message: 'Parámetros requeridos faltantes',
          details: exception.message 
        }, status: :bad_request
      end
      
      def render_success(data = {}, message = 'Operación exitosa')
        render json: {
          status: 'success',
          message: message,
          data: data
        }
      end
      
      def render_error(message = 'Error en la operación', status = :unprocessable_entity)
        render json: {
          status: 'error',
          message: message
        }, status: status
      end
    end
  end
end 