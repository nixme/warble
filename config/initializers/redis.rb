config = YAML.load_file(Rails.root.join('config', 'redis.yml'))

Ohm.connect :host => config['host'],
            :port => config['port']
