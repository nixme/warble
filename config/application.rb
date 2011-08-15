require File.expand_path('../boot', __FILE__)

# require 'active_record/railtie'
require 'action_controller/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end


module Warble
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified
    # here. Application configuration should go into files in
    # config/initializers -- all .rb files in that directory are automatically
    # loaded.

    # Custom directories with classes and modules that will autoload.
    config.autoload_paths += %W(#{config.root}/lib)

    # Default time zone
    config.time_zone = 'Pacific Time (US & Canada)'

    # Default locale for translated strings
    config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Name of the redis pubsub channel used for communicating with clients
    config.pubsub_channel = 'Jukebox:player'
  end
end
