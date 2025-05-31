class CreateWatchedEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :watched_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.date :watched_on # Fecha en que se vio la película (opcional al crear)

      t.timestamps
    end
    add_index :watched_entries, [:user_id, :movie_id], unique: true
  end
end