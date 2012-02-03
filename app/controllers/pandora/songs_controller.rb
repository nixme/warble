class Pandora::SongsController < Pandora::BaseController
  respond_to :json

  def index
    begin
      station = current_user.pandora_client(session).stations.find { |s| s.id == params[:station_id] }
      pandora_songs = station.next_playlist   # grab 4 songs

      # convert pandora API objects to our song objects
      songs = pandora_songs.map do |pandora_song|
        Song.find_or_create_from_pandora_song(pandora_song, current_user)
      end

      respond_with songs
    rescue   # assuming end of playlist here but should check for the right exception
      head 403
    end
  end
end
