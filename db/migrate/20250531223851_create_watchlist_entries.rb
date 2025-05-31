class CreateWatchlistEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :watchlist_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true

      t.timestamps
    end
    add_index :watchlist_entries, [:user_id, :movie_id], unique: true
  end
end