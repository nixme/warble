source 'http://rubygems.org'

gem 'rails', '3.1.3'

# Datastore adapters
gem 'pg'                                # PostgreSQL adapter
gem 'foreigner'                         # Foreign key constraints in migrations
gem 'hiredis'                           # ruby bindings for fast redis C lib
gem 'redis'                             # ruby redis interface
gem 'ohm'                               # simple ORM on redis

# Full-text search
gem 'sunspot_rails', '1.3.0.rc6'        # Apache Solr adapter

# Async processing
gem 'resque', require: 'resque/server'

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
end

# Miscellaneous gems
gem 'crypt19'                           # for pandora encryption
gem 'nokogiri'                          # HTML parsing
gem 'patron'                            # libcurl (HTTP) ruby bindings
gem 'execjs'                            # JS executor, used for scraping


group :test do
  gem 'turn', '0.8.2', require: false   # Pretty printed test output
end

group :development do
  gem 'foreman'                         # process launcher (Profile executor)
  gem 'thin'                            # web server
  gem 'capistrano'                      # deployment helpers
  gem 'sunspot_solr', '1.3.0.rc6'       # Simple local Solr server
end
