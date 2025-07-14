require "application_system_test_case"

class RecommendationsTest < ApplicationSystemTestCase
  # Test funcional 2: Sistema de Recomendaciones
  # Objetivo: Verificar que el sistema genera recomendaciones personalizadas basadas en preferencias del usuario

  def setup
    @user = users(:one)
    @action_genre = genres(:action)
    @drama_genre = genres(:drama)
    @director = directors(:nolan)
    
    # Crear películas de diferentes géneros y directores
    @action_movie1 = movies(:action_movie1)
    @action_movie2 = movies(:action_movie2)
    @action_movie3 = movies(:action_movie3)
    @action_movie4 = movies(:action_movie4)
    @action_movie5 = movies(:action_movie5)
    
    @nolan_movie1 = movies(:nolan_movie1)
    @nolan_movie2 = movies(:nolan_movie2)
    @nolan_movie3 = movies(:nolan_movie3)
    
    @recommendation_candidate = movies(:recommendation_candidate)
    
    sign_in @user
  end

  test "sistema detecta preferencias del usuario" do
    # 1. Usuario nuevo se registra en el sistema (ya está en setup)
    
    # 2. Marca 5 películas de género "Acción" como favoritas
    mark_movie_as_favorite(@action_movie1)
    mark_movie_as_favorite(@action_movie2)
    mark_movie_as_favorite(@action_movie3)
    mark_movie_as_favorite(@action_movie4)
    mark_movie_as_favorite(@action_movie5)
    
    # 3. Marca 3 películas del director "Christopher Nolan" como favoritas
    mark_movie_as_favorite(@nolan_movie1)
    mark_movie_as_favorite(@nolan_movie2)
    mark_movie_as_favorite(@nolan_movie3)
    
    # 4. Accede al dashboard
    visit dashboard_path
    
    # 5. Verifica que aparecen recomendaciones
    assert_text "Recomendaciones para ti"
    assert_selector ".recommendation-card", minimum: 1
  end

  test "recomendaciones incluyen películas de géneros preferidos" do
    # Preparar: marcar películas de acción como favoritas
    mark_movie_as_favorite(@action_movie1)
    mark_movie_as_favorite(@action_movie2)
    mark_movie_as_favorite(@action_movie3)
    
    visit dashboard_path
    
    # Verificar que las recomendaciones incluyen películas de acción
    within ".recommendations-section" do
      assert_text "Basado en tus gustos por ciertos géneros"
    end
  end

  test "recomendaciones incluyen películas de directores preferidos" do
    # Preparar: marcar películas de Nolan como favoritas
    mark_movie_as_favorite(@nolan_movie1)
    mark_movie_as_favorite(@nolan_movie2)
    
    visit dashboard_path
    
    # Verificar que las recomendaciones incluyen películas del director
    within ".recommendations-section" do
      assert_text "Basado en tus directores favoritos"
    end
  end

  test "no se recomiendan películas ya marcadas por el usuario" do
    # Preparar: marcar algunas películas como favoritas
    mark_movie_as_favorite(@action_movie1)
    mark_movie_as_favorite(@action_movie2)
    
    visit dashboard_path
    
    # Verificar que las películas marcadas no aparecen en recomendaciones
    assert_no_text @action_movie1.title
    assert_no_text @action_movie2.title
  end

  test "recomendaciones se actualizan al agregar nuevas preferencias" do
    # Estado inicial: sin preferencias
    visit dashboard_path
    assert_text "Aún no tenemos suficientes datos para generar recomendaciones"
    
    # Agregar primera preferencia
    mark_movie_as_favorite(@action_movie1)
    visit dashboard_path
    assert_text "Basado en tus gustos por ciertos géneros"
    
    # Agregar preferencia de director
    mark_movie_as_favorite(@nolan_movie1)
    visit dashboard_path
    assert_text "Basado en tus gustos por ciertos géneros y directores"
  end

  test "usuario sin preferencias ve mensaje informativo" do
    visit dashboard_path
    
    assert_text "Aún no tenemos suficientes datos para generar recomendaciones"
    assert_text "¡Explora y marca tus películas!"
  end

  private

  def mark_movie_as_favorite(movie)
    visit movie_path(movie)
    click_on "Agregar a favoritos"
    assert_text "Película agregada a favoritos"
  end
end 