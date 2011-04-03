require 'openid/fetchers'
require 'openid/store/filesystem'

# proper SSL verfication, prevents warnings
OpenID.fetcher.ca_file = Rails.root.join('config', 'ca-bundle.crt')

# setup google apps authentication for manymoon.com through omniauth
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_apps, OpenID::Store::Filesystem.new('/tmp'), :domain => 'manymoon.com'
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET']
end
