require './app'

use Rack::Reloader, 0 if development?
run Sinatra::Application
