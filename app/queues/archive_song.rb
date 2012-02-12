Queues::Archive = GirlFriday::WorkQueue.new(
    :archiver,
    store:        GirlFriday::Store::Redis,
    store_config: { pool: $redis_pool },
    size:         3
  ) do |id|

  sleep 1                  # Avoid a bit of DB contention. TODO
  if song = Song.find(id)
    song.archive!          # Archive song to disk
  end
end
