web:    bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: bundle exec sidekiq -q push,5 -q indexing,2 -q archiving,1 -c 10
push:   bundle exec thin start -R push/faye.ru -p 9292 -e production
search: bundle exec springboard -c config/elasticsearch -f
