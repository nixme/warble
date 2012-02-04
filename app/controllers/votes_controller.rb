class VotesController < ApplicationController
  before_filter :authenticate_user!

  def create
    begin
      if Song.find(params[:song_id]).votes.create(user: current_user).save
        head :created
      else
        head :forbidden
      end

    rescue ActiveRecord::RecordNotUnique
      head :not_modified
    end
  end
end
