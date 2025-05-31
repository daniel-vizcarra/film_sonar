# app/models/external_rating.rb
class ExternalRating < ApplicationRecord
  belongs_to :movie

  after_save :update_movie_weighted_score
  after_destroy :update_movie_weighted_score

  SOURCES = ["IMDb", "RottenTomatoes", "Letterboxd"].freeze
  VOTE_CAP = 250000 # Nuestro tope de votos para la ponderación

  validates :source_name, presence: true, inclusion: { in: SOURCES, message: "fuente no válida. Usar: #{SOURCES.join(', ')}" }
  validates :score, presence: true
  validates :movie_id, uniqueness: { scope: :source_name, message: "ya tiene una calificación para esta fuente y película" }
  validates :vote_count, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }

  # Método para obtener el puntaje normalizado (0-100)
  def normalized_score
    return nil unless score.present?

    # Extraer el valor numérico del string de puntaje
    numeric_value_match = score.match(/(\d+(\.\d+)?)/)
    return nil unless numeric_value_match
    numeric_value = numeric_value_match[1].to_f

    case source_name
    when "IMDb" # Escala 0-10
      (numeric_value * 10).round(2)
    when "RottenTomatoes" # Escala 0-100 (porcentaje)
      numeric_value.round(2)
    when "Letterboxd" # Escala 0-5
      ((numeric_value / 5.0) * 100).round(2)
    else
      nil # Fuente desconocida
    end
  end

  # Método para obtener los votos efectivos (con el tope)
  def effective_vote_count
    return 0 unless vote_count.present? && vote_count > 0
    [vote_count, VOTE_CAP].min
  end

  private

  def update_movie_weighted_score
    movie.update_weighted_score! # Llama al método en el modelo Movie
  end
end