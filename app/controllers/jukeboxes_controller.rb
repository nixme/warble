class JukeboxesController < ApplicationController
  # App bootstrap

  def app
  end

  # TODO: Re-add protection
  def index
    jukeboxes = Jukebox.all
    render json: jukeboxes
  end

  def create
    jukebox = Jukebox.new
    jukebox.update_attributes params[:jukebox]
    if jukebox.save
      head :created
    end
  end

  # Player page bootstrap
  def player
    @rdio_client_id = ENV['RDIO_CLIENT_ID']
    @rdio_token = Rdio::Client.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET']).playback_token(request.host)
  end

  def show
    render json: current_jukebox
  end

  def skip
    # TODO: only move forward if sent song id = current id, prevent multiple players from skipping too fast
    current_jukebox.skip
    head :ok
  end

  def volume
    current_jukebox.volume = params[:value]
    if current_jukebox.save
      head :ok
    end
  end

  # Rdio JS API authentication helper shim
  def rdio_helper
    render layout: false
  end

private
  def current_jukebox
    @current_jukebox ||= Jukebox.find(params[:id])
  end

end
