class Movie < ApplicationRecord
    has_and_belongs_to_many :genres
    belongs_to :director, optional: true
  
    validates :title, presence: true # Asegura que el título no esté vacío
    validates :release_year, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1880, less_than_or_equal_to: Date.current.year + 5 } # Asegura que el año sea un número y esté en un rango razonable
  end