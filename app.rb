$: << './lib'

require 'openid/store/filesystem'
require 'securerandom'
require 'pandora/client'
require 'json'

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
  attribute :pandora_id   # id for pandora songs
  reference :user, User   # user who added the song
  set :lovers, User       # users who liked the song
  set :haters, User       # users who disliked the song

  index :pandora_id

  def self.from_pandora_song(pandora_song)
    Song.new({
      source:     'pandora',
      title:      pandora_song.title,
      artist:     pandora_song.artist,
      album:      pandora_song.album,
      cover_url:  pandora_song.art_url || pandora_song.artist_art_url,
      url:        pandora_song.audio_url,
      pandora_id: pandora_song.music_id
    })
  end

  def to_hash
    super.merge :source     => source,
                :title      => title,
                :artist     => artist,
                :album      => album,
                :cover_url  => cover_url,
                :url        => url,
                :local_path => local_path,
                :pandora_id => pandora_id,
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

  def skip!
    if upcoming.empty?
      self.current = nil
    else
      played << self.current if self.current   # add current song to played list
      self.current = upcoming.shift            # pull next song from queue
    end

    save

    # notify clients
    $redis.publish(PUBSUB_CHANNEL, {
      event:   'skip',
      jukebox: Jukebox.app   # TODO: send removing song and client should validate, if wrong, refetch whole queue
    }.to_json)
  end

  def add_song(song)                  # TODO: ensure transactional
    upcoming << song                  # add song to end of queue

    # notify clients of new song
    $redis.publish(PUBSUB_CHANNEL, {
      event: 'add',
      song:   song
    }.to_json)

    skip! if self.current.nil?        # pick next song if nothing playing
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

post '/player/skip' do   # TODO: only move forward if sent song id = current id, prevent multiple players from skipping too fast
  Jukebox.app.skip!
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

post '/app/pandora/credentials/clear' do
  @user.pandora_username = nil
  @user.pandora_password = nil
  @user.save
  200
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
  station = @user.pandora_client.stations.find { |s| s.id == params[:station_id] }
  songs = station.next_playlist   # grab 4 songs

  # add songs to db
  songs.map do |pandora_song|
    song = Song.from_pandora_song(pandora_song)
    song.user = User[session[:user_id]]
    song.save
    song
  end.to_json
end

get '/app/jukebox' do   # TODO: remove this once application.coffee refactored
  Jukebox.app.to_json
end

get '/app/current' do
  Jukebox.app.current.to_json
end

get '/app/queue' do
  Jukebox.app.upcoming.all.to_json
end

post '/app/queue' do
  # TODO: allow inserting at top of queue
  song_ids = params[:song_id]
  if params[:song_id]
    song_ids.each do |song_id|
      Jukebox.app.add_song(Song[song_id])
    end
    200
  else
    500
  end
end
