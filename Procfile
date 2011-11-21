web:    bundle exec rails server thin -p $PORT
worker: bundle exec rake resque:work QUEUE=*
push:   cd push && npm run-script start
