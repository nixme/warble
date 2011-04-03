$: << './lib'

require 'openid/store/filesystem'
require 'securerandom'
require 'pandora/client'
require 'json'

enable :logging
enable :sessions
enable :method_override


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


# SERVER PLAYER

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
  begin
    station = @user.pandora_client.stations.find { |s| s.id == params[:station_id] }
    songs = station.next_playlist   # grab 4 songs

    # add songs to db
    songs.map do |pandora_song|
      song = Song.from_pandora_song(pandora_song)
      song.user = User[session[:user_id]]
      song.save
      song
    end.to_json
  rescue   # assuming end of playlist here but should check for the right exception
    403
  end
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
