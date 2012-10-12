module Rdio
  class SongsController < ApplicationController

    def index
      return render(json: []) unless params[:query].present?

      tracks = rdio_client.search(params[:query], 'Track', true, 'bigIcon')

      songs = tracks.map do |track|
        Song.find_or_create_from_rdio_song(track, current_user)
      end

      render json: songs
    end


   private

    def rdio_client
      @rdio_client ||= Rdio::Client.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET'])
    end
  end
end
