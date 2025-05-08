# syntax=docker/dockerfile:1

FROM ruby:3.3.7-slim

# Variables de entorno para desarrollo
ENV LANG C.UTF-8
ENV RAILS_ENV=development
ENV RACK_ENV=development
ENV BUNDLE_PATH="/usr/local/bundle"
ENV GEM_HOME="/usr/local/bundle"
ENV PATH="/usr/local/bundle/bin:${PATH}"

# Instalar dependencias del sistema
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

# Instalar gemas incluyendo las de desarrollo
RUN bundle install --jobs $(nproc) --retry 3 --with development test

# Copiar el resto del código de la aplicación
COPY . .

# Asegurarse de que los scripts sean ejecutables
RUN chmod +x bin/rails

# Exponer el puerto en el que correrá la aplicación Rails
EXPOSE 3000