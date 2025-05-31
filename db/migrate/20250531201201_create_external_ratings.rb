# db/migrate/xxxxxxxxxxxxxx_create_external_ratings.rb
class CreateExternalRatings < ActiveRecord::Migration[8.0] # O la versión que uses
  def change
    create_table :external_ratings do |t|
      t.references :movie, null: false, foreign_key: true
      t.string :source_name
      t.string :score
      t.integer :vote_count

      t.timestamps
    end
    # Opcional: Añadir un índice para búsquedas rápidas y asegurar unicidad
    add_index :external_ratings, [:movie_id, :source_name], unique: true
  end
end