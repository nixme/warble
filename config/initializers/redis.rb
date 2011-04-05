config = YAML.load_file(Rails.root.join('config', 'redis.yml'))

Ohm.connect :host => config['host'],
            :port => config['port']

# re-use Ohm's redis connection info for Resque
Resque.redis = Ohm.redis
