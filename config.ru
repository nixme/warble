# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# Include the log tailer. We run through `unicorn`, not `rails server` which
# automatically adds it.
use Rails::Rack::LogTailer

run Warble::Application
