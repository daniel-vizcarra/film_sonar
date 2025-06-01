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

puts "\n----> Seeding Directors..."
directors_to_seed = [
  { name: "Francis Ford Coppola", bio: "Director de El Padrino." },
  { name: "Quentin Tarantino", bio: "Director de Pulp Fiction." },
  { name: "Christopher Nolan", bio: "Director de Inception y The Dark Knight." },
  { name: "Martin Scorsese", bio: "Director de Goodfellas y Taxi Driver." },
  { name: "Steven Spielberg", bio: "Director de E.T. y Jurassic Park." }
]

directors_to_seed.each do |director_attrs|
  Director.find_or_create_by!(name: director_attrs[:name]) do |director|
    director.bio = director_attrs[:bio]
    # director.photo_url = "URL_DE_EJEMPLO_SI_TIENES" # Opcional
    puts "Creating Director: #{director.name}"
  end
end
puts "----> Finished seeding directors."

puts "\n----> Seeding Default Admin User..."
admin_email = "admin@filmsonar.com" # Puedes cambiar este email si lo deseas
admin_password = "password123"     # ESTA ES UNA CONTRASEÑA TEMPORAL

# Usamos find_or_create_by! para evitar crear el usuario si ya existe
User.find_or_create_by!(email: admin_email) do |user|
  user.password = admin_password
  user.password_confirmation = admin_password
  user.role = 'manager'
  # Si tuvieras el módulo :confirmable de Devise activado (no lo hemos hecho por defecto),
  # necesitarías algo como: user.skip_confirmation!
  puts "Admin user '#{user.email}' created/ensured with a temporary password."
end

puts "----> IMPORTANT: If this is the first time seeding or in a new production environment,"
puts "----> log in as '#{admin_email}' with password '#{admin_password}' and CHANGE THE PASSWORD IMMEDIATELY."

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