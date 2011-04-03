class Pandora::SongsController < Pandora::BaseController
  respond_to :json

  def index
    begin
      station = current_user.pandora_client.stations.find { |s| s.id == params[:station_id] }
      pandora_songs = station.next_playlist   # grab 4 songs

      # add songs to db
      songs = pandora_songs.map do |pandora_song|
        song = Song.from_pandora_song(pandora_song)
        song.user = current_user
        song.save
        song
      end
      respond_with songs
    rescue   # assuming end of playlist here but should check for the right exception
      head 403
    end
  end

end
