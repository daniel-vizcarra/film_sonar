# db/migrate/xxxxxxxx_add_weighted_score_to_movies.rb
class AddWeightedScoreToMovies < ActiveRecord::Migration[8.0]
  def change
    add_column :movies, :weighted_score, :decimal, precision: 5, scale: 2 # Ej: para puntajes como 88.75
  end
end