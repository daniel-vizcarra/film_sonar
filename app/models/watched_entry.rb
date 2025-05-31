class WatchedEntry < ApplicationRecord
  belongs_to :user
  belongs_to :movie
  validates :user_id, uniqueness: { scope: :movie_id, message: "ya ha sido marcada como vista." }
  # validates :watched_on, presence: true # Si la fecha es obligatoria
end