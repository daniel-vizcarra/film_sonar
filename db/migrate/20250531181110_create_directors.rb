class CreateDirectors < ActiveRecord::Migration[8.0]
  def change
    create_table :directors do |t|
      t.string :name
      t.text :bio
      t.string :photo_url

      t.timestamps
    end
  end
end
