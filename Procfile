web:    bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: bundle exec sidekiq -q indexing,2 -q archiving,1 -c 10
push:   cd push && npm run-script start
search: bundle exec springboard -c config/elasticsearch -f
