class VotesController < ApplicationController
  before_filter :authenticate_user!

  def create
    begin
      song = Song.find(params[:song_id])
      vote = song.votes.build()
      vote.user = current_user
      if vote.save
        render json:   song.as_json(),
               status: :created
      else
        head :forbidden
      end

      Jukebox.publish_change_event

    rescue ActiveRecord::RecordNotUnique
      head :not_modified
    end
  end
end
