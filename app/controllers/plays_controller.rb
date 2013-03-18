class PlaysController < ApplicationController

  # TODO: Don't think we need this.
  #
  # def index
  #  render json: current_jukebox.queue
  # end

  def create
    song_ids = params[:song_id]


    if song_ids
      song_ids.each do |song_id|
        Jukebox.enqueue(Song.find(song_id), current_user)
      end
      head :created

    # TODO: Genericize partner params.
    elsif params[:youtube]
      song = Song.find_or_create_from_youtube_params(params[:youtube], current_user)
      Jukebox.enqueue(song, current_user)
      head :created

    else
      head :forbidden
    end
  end

 private

  def current_jukebox
    @current_jukebox ||= Jukebox.find(params[:id])
  end

end
