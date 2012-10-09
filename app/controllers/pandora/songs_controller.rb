module Pandora
  class SongsController < BaseController
    respond_to :json

    def index
      retry_on_auth_failure do |pandora_client|
        station = pandora_client.stations.find { |s| s.id == params[:station_id] }   # TODO: use the token and we don't need the extra `stations` call here
        pandora_songs = station.next_songs   # grab 4 songs

        # Speed up grabbing music IDs by doing network fetches concurrently
        pandora_songs.map do |pandora_song|
          Thread.new { pandora_song.id }
        end.each(&:join)

        # convert pandora API objects to our song objects
        songs = pandora_songs.map do |pandora_song|
          ::Song.find_or_create_from_pandora_song(pandora_song, current_user)
        end

        respond_with songs
      end
    end
  end
end
