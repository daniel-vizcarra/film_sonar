class AddDirectorReferenceToMovies < ActiveRecord::Migration[8.0] # O la versión que uses
  def change
    # Añade la nueva columna director_id que referencia a la tabla directors.
    # null: true permite que una película no tenga director asignado (temporalmente o si es el caso).
    # foreign_key: true crea la restricción de clave foránea.
    add_reference :movies, :director, null: true, foreign_key: true

    # Elimina la antigua columna 'director' de tipo string.
    # Antes de ejecutar esto en un sistema con datos reales, te asegurarías de migrar los datos.
    # Por ahora, para nuestro desarrollo, la eliminaremos.
    remove_column :movies, :director, :string
  end
end