# Register third-party authentication providers
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], scope: 'email'
  provider :rdio, ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET']
end

OmniAuth.config.logger = Rails.logger
