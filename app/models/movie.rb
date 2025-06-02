class Movie < ApplicationRecord
  belongs_to :director, optional: true
  has_and_belongs_to_many :genres
  has_many :external_ratings, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favoriting_users, through: :favorites, source: :user
  has_many :watched_entries, dependent: :destroy

  has_many :watchlist_entries, dependent: :destroy

  accepts_nested_attributes_for :external_ratings,
                                allow_destroy: true,
                                reject_if: :all_blank

  validates :title, presence: true

  # Calcula el puntaje ponderado
  def calculate_weighted_score


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

    self.update_column(:weighted_score, new_score)
  end
end