source 'http://rubygems.org'

gem 'rails', '3.2.8'

# Datastore adapters
gem 'pg'                                # PostgreSQL adapter
gem 'foreigner'                         # Foreign key constraints in migrations
gem 'redis'                             # Redis adapter
gem 'connection_pool'                   # Simple connection pooling

# API clients and adapters
gem 'faraday'                           # Flexible HTTP client library
gem 'faraday_middleware'                # Request/response middleware for Faraday
gem 'pandora_client'                    # Pandora Tuner API client

# Full-text search
gem 'tire'                              # ElasticSearch adapter

# Async processing
gem 'sidekiq'                           # Threaded, Resque-compatible task queues
gem 'sinatra', require: false           # Mini web framework [only for Sidekiq::Web]
gem 'slim', '<= 1.3.0'                  # Simple templating [only for Sidekiq::Web]

# Authentication
gem 'omniauth-facebook'

# Front-end asset helpers
gem 'haml', '3.2.0.beta.3'              # HTML pre-processor

# Front-end asset helpers not loaded in production
group :assets do
  gem 'sass-rails'                      # CSS pre-processor
  gem 'compass-rails'                   # CSS helpers and mixins
  gem 'coffee-rails'                    # CoffeeScript compiling
  gem 'uglifier'                        # JavaScript minifer

  # Vendor JavaScript libraries
  gem 'jquery-rails'
  gem 'rails-behaviors'
  gem 'rails-backbone'
  gem 'swfobject-rails'
end

# Push server gems. Not loaded by main Rails app.
group :push do
  gem 'faye'                            # Pub/sub to the browser
  gem 'faye-redis'                      # Redis backend for Faye state
  gem 'thin'                            # Evented web server
end

# Miscellaneous gems
gem 'nokogiri'                          # HTML parsing
gem 'patron'                            # libcurl (HTTP) ruby bindings
gem 'execjs'                            # JS executor, used for scraping


group :development do
  gem 'foreman'                         # process launcher (Profile executor)
  gem 'puma'                            # Application server
  gem 'capistrano'                      # deployment helpers
  gem 'springboard'                     # Simple local ElasticSearch server
end

group :development, :test do
  gem 'jazz_hands'                      # Pry-based Rails console + goodies
end
