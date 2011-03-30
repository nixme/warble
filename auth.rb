helpers do
  def authenticated?
    session[:user_id]
  end
end

# setup google apps authentication for manymoon.com through omniauth
use OmniAuth::Builder do
  provider :google_apps, OpenID::Store::Filesystem.new('/tmp'), :domain => 'manymoon.com'
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET']
end

post '/auth/google_apps/callback' do
  user = User.find_or_create_by_google_auth(request.env['omniauth.auth'])
  session[:user_id] = user.id
  redirect to('/')
end

post '/auth/facebook/callback' do
  # assume user is already logged-in. this is to get their profile photo only
  @user = User[session[:user_id]]
  @user.photo_url = request.env['omniauth.auth']['user_info']['image']
  @user.save
  redirect to('/')
end

get '/auth/failure' do
  'Uh oh... something went wrong authenticating you'
end

# TODO: should be a DELETE (or POST at least)
get '/logout' do
  session.clear
  redirect to('/')
end