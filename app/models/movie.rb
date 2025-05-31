# app/models/movie.rb
class Movie < ApplicationRecord
  belongs_to :director, optional: true
  has_and_belongs_to_many :genres
  has_many :external_ratings, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favoriting_users, through: :favorites, source: :user
  has_many :watched_entries, dependent: :destroy
  # has_many :watching_users, through: :watched_entries, source: :user # Opcional si necesitas esta info

  has_many :watchlist_entries, dependent: :destroy
  # has_many :users_with_movie_in_watchlist, through: :watchlist_entries, source: :user # Opcional

  accepts_nested_attributes_for :external_ratings,
                                allow_destroy: true,
                                reject_if: :all_blank

  validates :title, presence: true
  # ... (otras validaciones) ...

  # Calcula el puntaje ponderado
  def calculate_weighted_score
    # Asegurarse de que los ratings estén cargados para evitar N+1 si se llama en un bucle
    # Esto es más relevante si no se guarda el puntaje en la BD y se calcula al vuelo.
    # ratings_to_consider = self.external_ratings.includes(nil) # Carga los ratings si no están cargados

    sum_of_weighted_scores = 0.0
    sum_of_effective_votes = 0

    self.external_ratings.each do |rating|
      norm_score = rating.normalized_score
      eff_votes = rating.effective_vote_count

      if norm_score && eff_votes > 0
        sum_of_weighted_scores += norm_score * eff_votes
        sum_of_effective_votes += eff_votes
      end
    end

    return nil if sum_of_effective_votes == 0 # Evita división por cero
    (sum_of_weighted_scores / sum_of_effective_votes).round(2)
  end

  def update_weighted_score!
    new_score = calculate_weighted_score
    # Usamos update_column para evitar validaciones/callbacks del modelo Movie y solo actualizar este campo.
    # O podrías usar self.weighted_score = new_score; self.save! si quieres que los callbacks de Movie se disparen.
    # Dado que esto se llama DESPUÉS de guardar un rating, update_column es más directo.
    self.update_column(:weighted_score, new_score)
  end
end