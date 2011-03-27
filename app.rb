$: << './lib'

require 'openid/store/filesystem'
require 'securerandom'
require 'pandora/client'
require 'json'

PUBSUB_CHANNEL = 'Jukebox:player'

configure do
  Ohm.connect

  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir     = 'views/stylesheets'
  end

  set :haml, :format => :html5
  set :sass, Compass.sass_engine_options

  redis = Redis.new
end

enable :logging
enable :sessions
enable :method_override


class User < Ohm::Model
  attribute :google_id
  attribute :token   # for authenticating websocket client since cookies won't pass
  attribute :first_name
  attribute :last_name
  attribute :email
  #attribute :domain
  attribute :photo_url
  attribute :pandora_username
  attribute :pandora_password

  index :google_id

  collection :songs, Song   # songs the user has added

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
                  :token      => SecureRandom.hex(10),
                  :google_id  => access_token['uid']
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def pandora_credentials?
    pandora_username && pandora_password
  end

  def pandora_client
    @pandora ||= Warble::Pandora::Client.new(pandora_username, pandora_password)
  end

  def to_hash
    super.merge :first_name => first_name,
                :last_name  => last_name,
                :email      => email,
                :photo_url  => photo_url,
  end
end

class Song < Ohm::Model
  attribute :source
  attribute :title
  attribute :artist
  attribute :album
  attribute :cover_url
  attribute :url          # url if appropriate for source
  attribute :local_path   # path if downloaded
  reference :user, User   # user who added the song
  set :lovers, User       # users who liked the song
  set :haters, User       # users who disliked the song

  def to_hash
    super.merge :source     => source,
                :title      => title,
                :artist     => artist,
                :album      => album,
                :cover_url  => cover_url,
                :url        => url,
                :local_path => local_path,
                :user       => user,
                :lovers     => lovers.all,
                :haters     => haters.all
  end
end

class Jukebox < Ohm::Model
  list      :played,   Song
  reference :current,  Song
  list      :upcoming, Song

  def to_hash
    super.merge :current => current
  end

  def self.app    # TODO: hack for the meantime until multiple jukebox support
    self.all.first || self.create
  end
end

helpers do
  def authenticated?
    session[:user_id]
  end

  def notify_clients
    redis.publish(PUBSUB_CHANNEL, Jukebox.app.to_json)
  end
end

# setup google apps authentication for manymoon.com through omniauth
use OmniAuth::Builder do
  provider :google_apps, OpenID::Store::Filesystem.new('/tmp'), :domain => 'manymoon.com'
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET']
end

post '/auth/google_apps/callback' do
  user = User.find_or_create_by_google_auth(request.env['omniauth.auth'])
  session[:user_id] = user.id
  redirect to('/')
end

post '/auth/facebook/callback' do
  # assume user is already logged-in. this is to get their profile photo only
  @user = User[session[:user_id]]
  @user.photo_url = request.env['omniauth.auth']['user_info']['image']
  @user.save
  redirect to('/')
end

get '/auth/failure' do
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

get '/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

get '/application.js' do coffee :application; end
get '/player.js'      do coffee :player;      end


# SERVER PLAYER

# TODO: protect this somehow?
get '/player' do
  haml :player
end

post '/player/next' do   # TODO: only move forward if sent song id = current id, prevent multiple players from skipping too fast
  jukebox = Jukebox.app
  next_song = jukebox.upcoming.shift
  jukebox.played << jukebox.current
  jukebox.current = next_song
  jukebox.save

  notify_clients
  200
end


# CLIENT VIEW

before '/app/*' do
  if authenticated?
    @user = User[session[:user_id]]
  else
    halt 403, 'Not logged in'
  end
end

post '/app/pandora/credentials' do
  @user.pandora_username = params[:pandora_username]
  @user.pandora_password = params[:pandora_password]
  @user.save
  200  # TODO: correct http code?
end

before '/app/pandora/stations*' do
  halt 401 unless @user.pandora_credentials?  # TODO: correct http code?
end

get '/app/pandora/stations' do
  @user.pandora_client.stations.map do |station|
    {
      name:  station.name,
      id:    station.id,
      token: station.token
    }
  end.to_json
end

get '/app/pandora/stations/:station_id/songs' do
  station = @user.pandora_client.stations.first { |s| s.id == params[:station_id] }
  station.next_playlist.map do |song|
    {
      title:          song.title,
      artist:         song.artist,
      album:          song.album,
      id:             song.music_id,
      audio_url:      song.audio_url,
      artist_id:      song.artist_id,
      art_url:        song.art_url,
      artist_art_url: song.artist_art_url
    }
  end.to_json
end

get '/app/current' do
  Jukebox.app.to_json
end

get '/app/queue' do
  Jukebox.app.upcoming.all.to_json
end

post '/app/queue' do
  @song = Song.new(params[:song])
  @song.user = @user
  @song.save

  notify_clients
  200
end
