source 'http://rubygems.org'

gem 'rails', '3.0.5'

# datastore
gem 'hiredis'                         # ruby bindings for fast redis C lib
gem 'redis'                           # ruby redis interface
gem 'ohm'                             # simple ORM on redis
gem 'sunspot_rails'                   # search through Solr

# async processing
gem 'resque', :require => 'resque/server'

# auth
gem 'omniauth'

# front-end
gem 'haml', '3.1.0.alpha.147'         # html pre-processor
gem 'sass', '3.1.0.alpha.252'         # css pre-processor
gem 'compass', '0.11.beta.5'          # css helpers and mixins
gem 'fancy-buttons', '1.1.0.alpha.1'  # css3 buttons
gem 'coffee-script'                   # js pre-processor
gem 'barista', '~> 1.0'               # coffeescript tooling
gem 'jammit'                          # asset packaging

# misc
gem 'crypt19'                         # for pandora encryption
gem 'nokogiri'                        # HTML parsing
gem 'patron'                          # libcurl (HTTP) ruby bindings
gem 'therubyracer'                    # embedded V8 engine, used for scraping


group :development do
  gem 'foreman'                       # process launcher (Profile executor)
  gem 'thin'                          # web server
  gem 'capistrano'                    # deployment helpers
end
