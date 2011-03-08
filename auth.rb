
# setup google apps authentication for manymoon.com through omniauth
use OmniAuth::Builder do
  provider :google_apps, OpenID::Store::Filesystem.new('/tmp'), :domain => 'manymoon.com'
end

post '/auth/:name/callback' do
  user = User.find_or_create_by_google_auth(request.env['omniauth.auth'])
  session[:user_id] = user.id
  redirect to('/')
end

post '/auth/:name/failure' do
  'Uh oh... something went wrong authenticating you'
end

get '/logout' do
  session.clear
  redirect to('/')
end
