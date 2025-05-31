# app/models/external_rating.rb
class ExternalRating < ApplicationRecord
  belongs_to :movie

  SOURCES = ["IMDb", "RottenTomatoes", "Letterboxd"].freeze

  validates :source_name, presence: true, inclusion: { in: SOURCES, message: "fuente no válida. Usar: #{SOURCES.join(', ')}" }
  validates :score, presence: true
  validates :movie_id, uniqueness: { scope: :source_name, message: "ya tiene una calificación para esta fuente y película" }
  validates :vote_count, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true } # Votos deben ser números >= 0
end