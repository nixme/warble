class JukeboxesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [ :size ]

  # App bootstrap

  def app
    @volume = Jukebox.volume
  end

  def size
    render json: Jukebox.queue.size
  end

  # Player page bootstrap
  def player
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
