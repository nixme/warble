$: << './lib'

require 'sinatra'
require 'omniauth'
require 'openid/store/filesystem'
require 'ohm'
require 'coffee-script'
require 'haml'
require 'sass'
require 'compass'
require 'fancy-buttons'

require 'pandora/client'

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
enable :run

class User < Ohm::Model
  attribute :google_id
  attribute :first_name
  attribute :last_name
  attribute :email
  attribute :profile_photo

  index :google_id

  def validations
    assert_unique :google_id
  end

  def self.find_or_create_by_google_auth(access_token)
    if user = find(:google_id => access_token['uid']).first
      user
    else   # no user found so create one!
      user_info = access_token['user_info']
      User.create :first_name => user_info['first_name'],
                  :last_name  => user_info['last_name'],
                  :email      => user_info['email'],
                  :google_id  => access_token['uid']
    end
  end
end

helpers do
  def authenticated?
    session[:user_id]
  end
end

# setup google apps authentication for manymoon.com through omniauth
use OmniAuth::Builder do
  provider :google_apps, OpenID::Store::Filesystem.new('/tmp'), :domain => 'manymoon.com'
end

post '/auth/:name/callback' do
  user = User.find_or_create_by_google_auth(request.env['omniauth.auth'])
  session[:user_id] = user.id
  redirect to('/')
end

post '/auth/:name/failure' do
  'Uh oh... something went wrong authenticating you'
end

# TODO: should be a DELETE (or POST at least)
get '/logout' do
  session.clear
  redirect to('/')
end

get '/' do
  if authenticated?
    @user = User[session[:user_id]]
    haml :app
  else
    haml :login
  end
end

get '/test' do
  haml :test
end

get '/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

get '/application.js' do
  coffee :application
end
