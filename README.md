# FilmSonar

Plataforma web para sugerencias personalizadas de películas con catálogo explorable, recomendaciones personalizadas basadas en preferencias y listas personales (vistas, favoritas).

## Tecnologías Principales

* **Backend:** Ruby on Rails 8.0.2
* **Frontend:** Hotwire (Turbo / Stimulus), Importmaps, Sass
* **Base de Datos:** PostgreSQL 15
* **Entorno de Desarrollo:** Docker, Docker Compose
* **Servidor:** Puma
* **Gestor de Procesos (Dev):** Foreman
* **Assets:** Propshaft, dartsass-rails
* **Versión de Ruby:** 3.3.7

## Prerrequisitos

* [Docker](https://www.docker.com/products/docker-desktop/) instalado.
* Docker Compose (generalmente viene con Docker Desktop).
* Git.

## Instalación y Ejecución (Entorno de Desarrollo)

1.  **Clonar el repositorio:**
    ```bash
    git clone <URL_DE_TU_REPOSITORIO_GIT>
    cd film_sonar
    ```

2.  **(Opcional) Variables de Entorno:** Si en el futuro se necesitan claves secretas (API keys, etc.), se gestionarán a través de variables de entorno o el gestor de credenciales de Rails. Por ahora, no se requieren archivos `.env` específicos.

3.  **Construir la imagen Docker:**
    (Necesario la primera vez o si se modifican `Dockerfile` o `Gemfile`)
    ```bash
    docker-compose build
    ```

4.  **Iniciar los servicios (Aplicación y Base de Datos):**
    ```bash
    docker-compose up
    ```
    Esto iniciará la aplicación, la base de datos y el compilador/watcher de Sass. Mantén esta terminal corriendo.

5.  **Preparar la Base de Datos (Solo la primera vez o si se borra el volumen):**
    Abre **otra terminal** en la misma carpeta del proyecto y ejecuta:
    ```bash
    # Crear las bases de datos de desarrollo y prueba
    docker-compose exec app bundle exec rails db:create

    # Aplicar las migraciones (crear tablas)
    docker-compose exec app bundle exec rails db:migrate

    # Poblar la base de datos con datos iniciales (ej. géneros)
    docker-compose exec app bundle exec rails db:seed
    ```

6.  **Acceder a la Aplicación:**
    Abre tu navegador web y visita: `http://localhost:3000`

## Comandos Útiles de Docker Compose

* **Iniciar servicios (en primer plano, muestra logs):** `docker-compose up`
* **Iniciar servicios (en segundo plano):** `docker-compose up -d`
* **Detener servicios:** `docker-compose down` (Si usaste `up -d` o desde otra terminal) o `Ctrl+C` (Si usaste `up` en primer plano).
* **Detener servicios Y ELIMINAR VOLÚMENES (¡Borra la BD!):** `docker-compose down -v`
* **Ver logs:** `docker-compose logs -f` (o `docker-compose logs -f app`, `docker-compose logs -f db`)
* **Ejecutar comandos Rails dentro del contenedor:**
    * Consola Rails: `docker-compose exec app bundle exec rails console`
    * Correr tests: `docker-compose exec app bundle exec rails test`
    * Ver rutas: `docker-compose exec app bundle exec rails routes`
    * Cualquier comando rake/rails: `docker-compose exec app bundle exec rails TU_COMANDO`
* **Reconstruir una imagen:** `docker-compose build NOMBRE_DEL_SERVICIO` (ej. `docker-compose build app`)

## Despliegue

*(Sección a completar cuando definamos la plataforma y el proceso de despliegue. Mencionaremos Render, Fly.io, etc.)*