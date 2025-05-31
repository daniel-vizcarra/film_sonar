class CreateFavorites < ActiveRecord::Migration[8.0] # O la versión que uses
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true

      t.timestamps
    end
    # Asegura que un usuario solo pueda tener una película como favorita una vez
    add_index :favorites, [:user_id, :movie_id], unique: true
  end
end