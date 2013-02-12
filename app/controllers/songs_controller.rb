class SongsController < ApplicationController

  skip_before_filter :authenticate_user!

  def index
    results =
      if params[:query].blank?
        []
      else
        Song.search(params[:query], load: true).results
      end
    render json: results
  end

  def reindex
    Song.all.each do |song|
      song.update_index
    end
    render json: {}
  end
end
