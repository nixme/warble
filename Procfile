web:       bundle exec rails server thin -p $PORT
worker:    bundle exec rake resque:work QUEUE=*
search:    bundle exec rake sunspot:solr:run
websocket: coffee server.coffee
