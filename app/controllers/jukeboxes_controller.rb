class JukeboxesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json

  # App bootstrap
  def app
    @volume = Jukebox.volume
  end

  # Player page bootstrap
  def player
  end

  def show
    render json: {
      current: Jukebox.current_song,
      volume:  Jukebox.volume
    }
  end

  def skip
    # TODO: only move forward if sent song id = current id, prevent multiple players from skipping too fast
    Jukebox.app.skip!
    head :ok
  end

  def volume
    Jukebox.volume = params[:value]
    head :ok
  end

  # TODO: move to more appropriate controller?
  def search
    if params[:query].blank?
      results = []
    else
      results = Sunspot.search(Song) { keywords params[:query] }.results
    end
    respond_with results
  end
end
