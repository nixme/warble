require 'rubygems'
require 'bundler'

Bundler.require

require './app'

use Rack::Reloader, 0 if development?
run Sinatra::Application
