source 'http://rubygems.org'

gem 'rails', '3.1.3'

# Datastore adapters
gem 'pg'                                # PostgreSQL adapter
gem 'foreigner'                         # Foreign key constraints in migrations
gem 'hiredis'                           # ruby bindings for fast redis C lib
gem 'redis'                             # ruby redis interface
gem 'connection_pool'                   # Simple connection pooling

# API clients and adapters
gem 'pandora_client'                    # Pandora Tuner API client

# Full-text search
gem 'tire'                              # ElasticSearch adapter

# Async processing
gem 'sidekiq', git: 'https://github.com/mperham/sidekiq.git'  # Threaded, Resque-compatible task queues

# Authentication
gem 'omniauth-facebook'

# Front-end
gem 'haml', '3.2.0.alpha.8'             # HTML pre-processor
group :assets do                        # Asset group not needed in production
  gem 'sass-rails', '~> 3.1.5'          # CSS pre-processor
  gem 'compass', '0.12.alpha'
  gem 'coffee-rails', '~> 3.1.1'        # CoffeeScript compiling
  gem 'uglifier', '>= 1.0.3'            # JavaScript minifer

  # Vendor JavaScript libraries
  gem 'jquery-rails'
  gem 'rails-behaviors'
  gem 'rails-backbone'
  gem 'swfobject-rails'
end

# Miscellaneous gems
gem 'crypt19'                           # for pandora encryption
gem 'nokogiri'                          # HTML parsing
gem 'patron'                            # libcurl (HTTP) ruby bindings
gem 'execjs'                            # JS executor, used for scraping


group :development do
  gem 'foreman'                         # process launcher (Profile executor)
  gem 'unicorn'                         # Application server
  gem 'capistrano'                      # deployment helpers
  gem 'springboard'                     # Simple local ElasticSearch server
end

group :development, :test do
  gem 'jazz_hands'                      # Pry-based Rails console + goodies
end
