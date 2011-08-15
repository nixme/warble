class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_or_create_by_facebook_auth(request.env['omniauth.auth'])
    session[:user_id] = user.id
    redirect_to root_url
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_url
  end

  def failure
    # TODO: replace with a proper fail page
    render :text => 'Uh oh... something went wrong authenticating you'
  end

  def update_with_facebook # TODO: implement and use
    # assume user is already logged-in. this is to get their profile photo only
    @user = User[session[:user_id]]
    @user.photo_url = request.env['omniauth.auth']['info']['image']
    @user.save
    redirect to('/')
  end
end
