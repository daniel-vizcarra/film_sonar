# db/seeds.rb

puts "----> Seeding Genres..."

# Lista de nombres de géneros comunes
genres_to_seed = [
  "Acción", "Aventura", "Animación", "Ciencia Ficción", "Comedia",
  "Crimen", "Documental", "Drama", "Fantasía", "Histórico",
  "Musical", "Misterio", "Romance", "Suspense", "Terror",
  "Bélico", "Western"
]

# Usamos find_or_create_by! para evitar duplicados si corremos db:seed múltiples veces.
# El bloque do |genre| solo se ejecuta si el género es nuevo.
genres_to_seed.each do |genre_name|
  Genre.find_or_create_by!(name: genre_name) do |genre|
    puts "Creating Genre: #{genre.name}"
  end
end

puts "----> Finished seeding genres."

# Más adelante, podríamos añadir aquí la creación de un usuario administrador por defecto
# o algunas películas de ejemplo.
# puts "\n----> Seeding Admin User..."
# User.find_or_create_by!(email: 'admin@filmsonar.com') do |user|
#   user.password = 'password' # Usa una contraseña segura o variables de entorno
#   user.password_confirmation = 'password'
#   user.role = 'manager'
#   puts "Creating Admin User: #{user.email}"
# end
# puts "----> Finished seeding admin user."