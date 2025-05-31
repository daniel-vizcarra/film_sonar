class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  validates :user_id, uniqueness: { scope: :movie_id, message: "ya ha sido marcada como favorita por este usuario" }
end