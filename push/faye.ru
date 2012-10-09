require 'faye'
require 'faye/redis'

redis_config = YAML.load_file(File.expand_path('../../config/redis.yml', __FILE__))

Faye::WebSocket.load_adapter('thin')  # Enable WebSocket support

run Faye::RackAdapter.new(
  mount: '/',
  timeout: 25,
  engine: {
    type: Faye::Redis,
    host: redis_config['host'],
    port: redis_config['port'],
    password: redis_config['password']
  }
)
