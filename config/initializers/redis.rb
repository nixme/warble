config = YAML.load_file(Rails.root.join('config', 'redis.yml'))
Resque.redis = $redis = Redis.new(host: config['host'], port: config['port'])

# Re-establish and close DB connection when forking because libpq connections
# cannot pass through fork().
Resque.after_fork = proc do
  ActiveRecord::Base.establish_connection
end
