require "application_system_test_case"

class FavoritesTest < ApplicationSystemTestCase
  # Test funcional 1: Sistema de Favoritos
  # Objetivo: Verificar que un usuario puede marcar y desmarcar películas como favoritas

  def setup
    @user = users(:one) # Asumiendo que tienes fixtures
    @movie = movies(:one)
    sign_in @user
  end

  test "usuario puede marcar película como favorita" do
    # 1. Usuario autenticado accede al catálogo de películas
    visit movies_path
    
    # 2. Selecciona una película no marcada como favorita
    click_on @movie.title
    
    # 3. Hace clic en el botón "Agregar a favoritos"
    click_on "Agregar a favoritos"
    
    # 4. Verifica que la película aparece en su lista de favoritos
    assert_text "Película agregada a favoritos"
    
    # 5. Verifica que la interfaz se actualiza inmediatamente
    assert_selector ".favorite-icon.favorited"
    
    # 6. Verifica que la película aparece en la página "Mis Favoritos"
    visit my_favorites_path
    assert_text @movie.title
  end

  test "usuario puede quitar película de favoritos" do
    # Preparar: agregar película a favoritos
    @user.favorites.create!(movie: @movie)
    
    # 1. Usuario accede a la página de la película
    visit movie_path(@movie)
    
    # 2. Hace clic en "Quitar de favoritos"
    click_on "Quitar de favoritos"
    
    # 3. Verifica que la película desaparece de su lista
    assert_text "Película removida de favoritos"
    
    # 4. Verifica que la interfaz se actualiza
    assert_selector ".favorite-icon:not(.favorited)"
    
    # 5. Verifica que no aparece en "Mis Favoritos"
    visit my_favorites_path
    assert_no_text @movie.title
  end

  test "cambios persisten en la base de datos" do
    visit movie_path(@movie)
    
    # Agregar a favoritos
    click_on "Agregar a favoritos"
    assert @user.favorites.exists?(movie: @movie)
    
    # Quitar de favoritos
    click_on "Quitar de favoritos"
    assert_not @user.favorites.exists?(movie: @movie)
  end

  test "usuario no autenticado no puede marcar favoritos" do
    sign_out @user
    visit movie_path(@movie)
    
    # No debe mostrar botón de favoritos
    assert_no_text "Agregar a favoritos"
    assert_no_text "Quitar de favoritos"
  end
end 