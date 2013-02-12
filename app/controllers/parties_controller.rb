class PartiesController < ApplicationController

  skip_before_filter :authenticate_user!

  def app
  end

  def show
    render json: {}
  end

end
