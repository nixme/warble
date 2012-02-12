# Load Redis connection configuration from config/redis.yml
config = YAML.load_file(Rails.root.join('config', 'redis.yml'))

# Create a global pool of connections
$redis_pool = ConnectionPool.new(size: 10, timeout: 10) do
  Redis.new host: config['host'], port: config['port']
end
