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
        Jukebox.app.add_song(Song[song_id])
      end
      head :created
    elsif params[:youtube]
      song = Song.from_youtube_params(params[:youtube])
      song.user = current_user
      song.save
      Jukebox.app.add_song(song)
      head :created
    else
      head 500
    end
  end
end
