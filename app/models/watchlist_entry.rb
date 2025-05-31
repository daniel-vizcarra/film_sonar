class WatchlistEntry < ApplicationRecord
  belongs_to :user
  belongs_to :movie
  validates :user_id, uniqueness: { scope: :movie_id, message: "ya está en tu watchlist." }
end