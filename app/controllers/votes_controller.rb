class VotesController < ApplicationController
  before_filter :authenticate_user!

  def create
    begin
      if (song = Song.find(params[:song_id]).votes.create(user: current_user)).save
        render json:   song.as_json(),
               status: :created
      else
        head :forbidden
      end

    rescue ActiveRecord::RecordNotUnique
      head :not_modified
    end
  end
end
