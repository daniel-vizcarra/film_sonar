class Director < ApplicationRecord
    has_many :movies, dependent: :nullify # O :destroy si prefieres que se borren las películas del director
  
    validates :name, presence: true, uniqueness: true # Es bueno tener el nombre del director como único
  end