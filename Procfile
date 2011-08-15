web:    bundle exec rails server thin -p $PORT
worker: bundle exec rake resque:work QUEUE=*
push:   coffee server.coffee
