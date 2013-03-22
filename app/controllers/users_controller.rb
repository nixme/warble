class UsersController < ApplicationController
  def index
    ids = params[:ids]
    users = User.where(id: ids)
    render json: users
  end
end
