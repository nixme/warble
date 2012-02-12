Queues::Index = GirlFriday::WorkQueue.new(
    :indexer,
    store:        GirlFriday::Store::Redis,
    store_config: { pool: $redis_pool },
    size:         2
  ) do |id|

  sleep 1                  # Avoid a bit of DB contention. TODO
  if song = Song.find(id)
    song.update_index      # Index song in ElasticSearch via tire
  end
end
