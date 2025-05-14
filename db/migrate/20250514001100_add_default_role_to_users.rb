class AddDefaultRoleToUsers < ActiveRecord::Migration[8.0] # o la versión que uses
  def change
    # Añade un valor por defecto 'user' a la columna role
    change_column_default :users, :role, from: nil, to: 'user'
    # Opcional: Asegurar que no sea nulo si siempre debe tener un rol
    change_column_null :users, :role, false, 'user'
  end
end