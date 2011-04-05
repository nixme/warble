class SongsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def index
    respond_with Jukebox.app.upcoming.all
  end

  def create
    # TODO: allow inserting at top of queue
    song_ids = params[:song_id]
    if song_ids
      song_ids.each do |song_id|
        Jukebox.app.add_song(Song[song_id], current_user)
      end
      head :created
    elsif params[:youtube]
      song = Song.find_or_create_from_youtube_params(params[:youtube], current_user)
      Jukebox.app.add_song(song, current_user)
      head :created
    else
      head 500
    end
  end
end
