# app/repositories/movie_repository.rb
class MovieRepository
  # Repository Pattern para acceso a datos de películas
  # Aplica el principio Single Responsibility: solo se encarga del acceso a datos de películas

  def find_all
    Movie.all.includes(:genres, :director, :external_ratings)
  end

  def find_by_filters(filters = {})
    query = Movie.all.includes(:genres, :director, :external_ratings)

    # Filtrar por géneros
    if filters[:genre_ids].present?
      query = query.joins(:genres).where(genres: { id: filters[:genre_ids] })
    end

    # Filtrar por directores
    if filters[:director_ids].present?
      query = query.where(director_id: filters[:director_ids])
    end

    # Filtrar por año
    if filters[:year_from].present?
      query = query.where('release_year >= ?', filters[:year_from])
    end

    if filters[:year_to].present?
      query = query.where('release_year <= ?', filters[:year_to])
    end

    # Filtrar por puntuación mínima
    if filters[:min_score].present?
      query = query.where('weighted_score >= ?', filters[:min_score])
    end

    query.distinct
  end

  def find_similar(movie, limit: 6)
    return [] unless movie.genres.any?

    genre_ids = movie.genre_ids

    # Buscar películas con géneros similares
    similar_movies = Movie.joins(:genres)
                         .where(genres: { id: genre_ids })
                         .where.not(id: movie.id)
                         .order("RANDOM()")
                         .limit(limit)

    # Si no hay suficientes películas similares, agregar películas aleatorias
    if similar_movies.count < limit
      remaining_count = limit - similar_movies.count
      additional_movies = Movie.where.not(id: [movie.id] + similar_movies.pluck(:id))
                              .order("RANDOM()")
                              .limit(remaining_count)
      
      similar_movies = similar_movies + additional_movies
    end

    similar_movies
  end

  def find_top_movies(limit: 10)
    Movie.where.not(weighted_score: nil)
         .order(weighted_score: :desc)
         .limit(limit)
         .includes(:genres, :director)
  end

  def find_by_id(id)
    Movie.includes(:genres, :director, :external_ratings).find(id)
  end

  def find_by_ids(ids)
    Movie.includes(:genres, :director, :external_ratings).where(id: ids)
  end

  def search_by_title(title, limit: 20)
    Movie.where("LOWER(title) LIKE ?", "%#{title.downcase}%")
         .order(:title)
         .limit(limit)
         .includes(:genres, :director)
  end

  def find_by_director(director_id, limit: 20)
    Movie.where(director_id: director_id)
         .order(release_year: :desc)
         .limit(limit)
         .includes(:genres, :director)
  end

  def find_by_genre(genre_id, limit: 20)
    Movie.joins(:genres)
         .where(genres: { id: genre_id })
         .order(weighted_score: :desc)
         .limit(limit)
         .includes(:genres, :director)
  end
end 