class SongsController < ApplicationController
  def index
    if params[:query].blank?
      results = []
    else
      results = Sunspot.search(Song) { keywords params[:query] }.results
    end
    respond_with results
  end
end
