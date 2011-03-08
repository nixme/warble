require 'sinatra'
require 'omniauth'
require 'openid/store/filesystem'
require 'mongoid'
require 'haml'
require 'sass'
require 'compass'
require 'fancy-buttons'

load './configuration.rb'
Dir['./models/*.rb'].each { |model| load model }

load './helpers.rb'
load './auth.rb'


get '/' do
  if authenticated?
    @user = User.find(session[:user_id])
    haml :app
  else
    haml :login
  end
end


get '/screen.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :screen
end
