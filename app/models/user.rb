class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :favorites, dependent: :destroy
  has_many :favorite_movies, through: :favorites, source: :movie        
  
  has_many :watched_entries, dependent: :destroy
  has_many :watched_movies, through: :watched_entries, source: :movie

  has_many :watchlist_entries, dependent: :destroy
  has_many :watchlist_movies, through: :watchlist_entries, source: :movie
end
