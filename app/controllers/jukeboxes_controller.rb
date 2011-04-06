class JukeboxesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json

  def show
    respond_with @jukebox = Jukebox.app
  end

  def player
  end

  def skip
    # TODO: only move forward if sent song id = current id, prevent multiple players from skipping too fast
    Jukebox.app.skip!
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
