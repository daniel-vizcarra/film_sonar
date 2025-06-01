# lib/tasks/import_movies.rake
require 'csv'

namespace :import do
  desc "Import movies, directors, genres, and ratings from lib/data/movies.csv"
  task movies: :environment do
    csv_file_path = Rails.root.join('lib', 'data', 'movies.csv')

    unless File.exist?(csv_file_path)
      puts "Error: El archivo #{csv_file_path} no fue encontrado."
      next
    end

    puts "Iniciando importación de películas desde CSV..."
    successful_movies = 0
    failed_movies = 0
    created_directors_count = 0
    created_genres_count = 0

    CSV.foreach(csv_file_path, headers: true) do |row|
      begin
        puts "Procesando película: #{row['title']}"

        # 1. Encontrar o Crear Director
        director = nil
        if row['director_name'].present?
          director = Director.find_or_create_by!(name: row['director_name'].strip) do |d|
            puts "  Nuevo Director creado: #{d.name}"
            created_directors_count += 1
          end
        end

        # 2. Encontrar o Crear Película
        movie = Movie.find_or_initialize_by(title: row['title'].strip)
        is_new_movie = movie.new_record?

        movie.description   = row['description']&.strip
        movie.release_year  = row['release_year'].to_i if row['release_year'].present?
        movie.director      = director
        movie.poster_url    = row['poster_url']&.strip

        if movie.save!
          if is_new_movie
            puts "  Película creada: #{movie.title}"
          else
            puts "  Película actualizada: #{movie.title}"
          end
        end

        # 3. Asociar Géneros
        if row['genre_names'].present?
          genre_names_array = row['genre_names'].split(',').map(&:strip)
          genre_names_array.each do |genre_name|
            genre = Genre.find_or_create_by!(name: genre_name) do |g|
              puts "    Nuevo Género creado: #{g.name}"
              created_genres_count += 1
            end
            movie.genres << genre unless movie.genres.include?(genre)
          end
        end

        # 4. Crear/Actualizar Calificaciones
        process_votes = ->(votes_str) { votes_str.present? ? votes_str.gsub(/\D/, '').to_i : nil }
        
        # Procesar calificaciones de IMDb
        if row['imdb_score'].present?
          external_rating = ExternalRating.find_or_initialize_by(movie: movie, source_name: "IMDb")
          external_rating.score = row['imdb_score'].strip
          external_rating.vote_count = process_votes.call(row['imdb_votes'])
          external_rating.save! if external_rating.changed? || external_rating.new_record?
        end

        # Procesar calificaciones de Rotten Tomatoes
        if row['rt_score'].present?
          external_rating = ExternalRating.find_or_initialize_by(movie: movie, source_name: "RottenTomatoes")
          external_rating.score = row['rt_score'].strip
          external_rating.vote_count = process_votes.call(row['rt_votes'])
          external_rating.save! if external_rating.changed? || external_rating.new_record?
        end

        # Procesar calificaciones de Letterboxd
        if row['letterboxd_score'].present?
          external_rating = ExternalRating.find_or_initialize_by(movie: movie, source_name: "Letterboxd")
          external_rating.score = row['letterboxd_score'].strip
          external_rating.vote_count = process_votes.call(row['letterboxd_votes'])
          external_rating.save! if external_rating.changed? || external_rating.new_record?
        end

        # 5. Actualizar puntaje ponderado
        movie.update_weighted_score!

        successful_movies += 1

      rescue => e
        puts "ERROR procesando película '#{row['title']}': #{e.message}"
        failed_movies += 1
      end
    end

    puts "\n--- Resumen de Importación ---"
    puts "#{successful_movies} películas procesadas/actualizadas exitosamente."
    puts "#{created_directors_count} nuevos directores creados."
    puts "#{created_genres_count} nuevos géneros creados."
    puts "#{failed_movies} películas con errores durante la importación."
  end
end