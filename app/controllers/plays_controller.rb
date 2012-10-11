class PlaysController < ApplicationController
  def index
    render json: Jukebox.queue
  end

  def create
    song_ids = params[:song_id]

    if song_ids
      song_ids.each do |song_id|
        Jukebox.enqueue(Song.find(song_id), current_user)
      end
      head :created
      
    elsif params[:soundcloud]
      song = Song.find_or_create_from_soundcloud_params(params[:soundcloud], current_user)
      Jukebox.enqueue(song, current_user)
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
