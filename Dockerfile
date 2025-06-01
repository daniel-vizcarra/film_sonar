# syntax=docker/dockerfile:1
# check=error=true

# --------------------------------------------------
# This Dockerfile is designed for production, not development.
# Build: docker build -t film_sonar .
# Run: docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value> --name film_sonar film_sonar
# For dev containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html
# --------------------------------------------------

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.7

# Base stage with runtime dependencies
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Set working directory
WORKDIR /rails

# Install base system packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libjemalloc2 \
      libvips \
      postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set environment variables
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# --------------------------------------------------
# Build stage with build dependencies and app compilation
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libyaml-dev \
      pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile application code with bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# Make bin scripts Linux-executable
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# Precompile assets with dummy secret
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# --------------------------------------------------
# Final production image
FROM base

# Copy built artifacts from build stage
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Crear y cambiar al usuario rails
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

# Cambiar al usuario rails
USER 1000:1000

# Exponer el puerto
EXPOSE 80

# Comando de inicio que ejecuta las migraciones, seeds y el servidor
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]