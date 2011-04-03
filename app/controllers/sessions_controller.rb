class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_or_create_by_google_auth(request.env['omniauth.auth'])
    session[:user_id] = user.id
    redirect_to root_url
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_url
  end
end
