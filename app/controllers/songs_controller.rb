class SongsController < ApplicationController
  def index
    results =
      if params[:query].blank?
        []
      else
        Song.search(params[:query], load: true).results
      end
    render json: results
  end
end
