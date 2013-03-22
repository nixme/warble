source 'http://rubygems.org'

gem 'rails',           github: 'rails/rails'
gem 'sass-rails',      github: 'rails/sass-rails'

# TODO: Migrate to new mass-assignment approach
gem 'protected_attributes'

# Datastore adapters
gem 'pg'                                # PostgreSQL adapter
gem 'foreigner'                         # Foreign key constraints in migrations
gem 'redis'                             # Redis adapter
gem 'connection_pool'                   # Simple connection pooling

# API clients and adapters
gem 'faraday'                           # Flexible HTTP client library
gem 'faraday_middleware'                # Request/response middleware for Faraday
gem 'pandora_client'                    # Pandora Tuner API client
gem 'rdio-ruby', git: 'https://github.com/nixme/rdio-ruby.git'

# Full-text search
gem 'tire', github: 'karmi/tire'        # ElasticSearch adapter

# Async processing
gem 'sidekiq'                           # Threaded, Resque-compatible task queues
gem 'sinatra', require: false           # Mini web framework [only for Sidekiq::Web]
gem 'slim', '<= 1.3.0'                  # Simple templating [only for Sidekiq::Web]

# Authentication
gem 'omniauth-facebook'
gem 'omniauth-rdio'

# Front-end asset helpers
gem 'ember-rails'
gem 'emblem-rails'
gem 'sass'
gem "haml", :github => "haml/haml", :branch => "stable"
gem 'sass-rails',      github: 'rails/sass-rails'

# Front-end asset helpers not loaded in production
group :assets do
  gem 'bourbon'
  gem 'animation', '~> 0.1.alpha.3'     # [TEMP] Sass CSS3 animation helpers. Remove after Compass 0.13 upgrade
  gem 'uglifier'                        # JavaScript minifer

  gem 'coffee-rails',    github: 'rails/coffee-rails'

  # This fork adds supports for Rails 4
  gem 'swfobject-rails', github: 'geraudmathe/swfobject-rails'
end

# Vendor JavaScript libraries
gem 'jquery-rails'
gem 'rails-behaviors'


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
  gem 'puma', '~> 2.0.0.b7'             # Application server
  gem 'capistrano'                      # deployment helpers
  gem 'springboard'                     # Simple local ElasticSearch server
end

group :development, :test do
  gem 'pry'
  gem 'pry-rails', :group => :development
  gem 'pry-debugger'
  gem 'jazz_hands'                      # Pry-based Rails console + goodies
end
