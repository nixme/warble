module Queues; end

# Load girl_friday queues. Not autoloading due to concurrency concerns.
Dir[Rails.root.join('app', 'queues', '*.rb')].each { |f| require f }
