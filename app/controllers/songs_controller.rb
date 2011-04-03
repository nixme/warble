class SongsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def index
    respond_with Jukebox.app.upcoming.all
  end

  def create
    # TODO: allow inserting at top of queue
    song_ids = params[:song_id]
    if params[:song_id]
      song_ids.each do |song_id|
        Jukebox.app.add_song(Song[song_id])
      end
      head :created
    else
      head 500
    end
  end
end
