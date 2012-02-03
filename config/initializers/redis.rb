config = YAML.load_file(Rails.root.join('config', 'redis.yml'))
Resque.redis = $redis = Redis.new(host: config['host'], port: config['port'])
