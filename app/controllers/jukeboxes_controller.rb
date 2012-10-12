class JukeboxesController < ApplicationController
  # App bootstrap

  def app
    @volume = Jukebox.volume
  end

  # Player page bootstrap
  def player
    @rdio_token = Rdio::Client.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET']).playback_token
  end

  def show
    render json: Jukebox
  end

  def skip
    # TODO: only move forward if sent song id = current id, prevent multiple players from skipping too fast
    Jukebox.skip
    head :ok
  end

  def volume
    Jukebox.volume = params[:value]
    head :ok
  end
end
