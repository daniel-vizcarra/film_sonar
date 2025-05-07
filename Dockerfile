# syntax=docker/dockerfile:1

# Usar la misma versión de Ruby que tu proyecto (del .ruby-version o Dockerfile.prod)
# La variante -slim es más ligera
FROM ruby:3.3.7-slim

# Variables de entorno para desarrollo
ENV LANG C.UTF-8
ENV RAILS_ENV=development
ENV RACK_ENV=development
ENV BUNDLE_PATH="/bundle_cache"
ENV GEM_HOME="/bundle_cache"
ENV BUNDLE_APP_CONFIG="/bundle_cache"

# Instalar dependencias del sistema
# - build-essential: Para compilar gemas nativas
# - libpq-dev: Para la gema 'pg' de PostgreSQL
# - nodejs & yarn: Para el pipeline de assets de Rails o si usas jsbundling-rails
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpq-dev \
    libyaml-dev \
    nodejs \
    yarn && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Establecer el directorio de trabajo
WORKDIR /rails

# Copiar los archivos de gestión de gemas
COPY Gemfile Gemfile.lock ./

# Instalar gemas. Esto se cacheará si Gemfile y Gemfile.lock no cambian.
# Incluye gemas de desarrollo y prueba.
RUN bundle install --jobs $(nproc) --retry 3

# Copiar el resto del código de la aplicación
COPY . .

# Exponer el puerto en el que correrá la aplicación Rails
EXPOSE 3000

# Comando por defecto para iniciar el servidor de Rails en modo desarrollo
# -b 0.0.0.0 hace que el servidor sea accesible desde fuera del contenedor
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]