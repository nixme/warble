class SongsController < ApplicationController
  before_filter :authenticate_user!

  def index
    render json: Jukebox.queue_as_songs
  end

  def create
    song_ids = params[:song_id]

    if song_ids
      song_ids.each do |song_id|
        Jukebox.enqueue(Song.find(song_id), current_user)
      end
      head :created

    elsif params[:youtube]
      song = Song.find_or_create_from_youtube_params(params[:youtube], current_user)
      Jukebox.enqueue(song, current_user)
      head :created

    else
      head :forbidden
    end
  end
end
