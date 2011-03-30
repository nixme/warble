PUBSUB_CHANNEL = 'Jukebox:player'
$redis = Redis.new

configure do
  Ohm.connect

  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir     = 'views/stylesheets'
  end

  set :haml, :format => :html5
  set :sass, Compass.sass_engine_options
end

enable :logging
enable :sessions
enable :method_override
