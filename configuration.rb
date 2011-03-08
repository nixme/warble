configure do
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir     = 'views/stylesheets'
  end

  set :haml, :format => :html5
  set :sass, Compass.sass_engine_options

  Mongoid.configure do |config|
    config.master = Mongo::Connection.from_uri('mongodb://localhost:27017').db('warble')
  end
end

enable :logging
enable :sessions
enable :run
