module Jukebox
  extend self

  # TODO: some of these need to be atomic ops

  def volume
    $redis_pool.with { |redis| redis.get('warble:volume').to_i }
  end

  def volume=(value)
    $redis_pool.with { |redis| redis.set('warble:volume', value.to_i) }
    publish_event 'volume'
  end

  def current_play
    play_id = $redis_pool.with { |redis| redis.get('warble:current_play') }
    Play.find_by_id(play_id)
  end

  def current_song
    play = current_play
    play && play.song
  end

  def queue
    $redis_pool.with do |redis|
      redis.zrange('warble:queue', 0, -1)
        .map { |play_id| Play.find_by_id(play_id) }
        .compact
    end
  end

  def enqueue(song, user = nil)
    priority = user ? user.number_of_plays_today : 999
    play = Play.create(user: user, song: song)

    $redis_pool.with { |redis| redis.zadd('warble:queue', priority, play.id) }

    publish_event 'refresh'

    skip unless current_play
  end

  def skip
    $redis_pool.with do |redis|
      if redis.zcard('warble:queue') == 0    # If nothing queued
        redis.del('warble:current_play')     # ...then kill current song
        enqueue Song.random                   # ...and auto-queue another song
      else
        results = redis.multi do                       # Pop from queue and set as current
          redis.zrange('warble:queue', 0, 0)
          redis.zremrangebyrank('warble:queue', 0, 0)
        end
        redis.set('warble:current_play', results.first.first)
      end
    end

    publish_event 'skip'
  end

  def publish_event(event)
    $redis_pool.with do |redis|
      redis.publish(Warble::Application.config.pubsub_channel, {
        event:   event,
        jukebox: as_json
      }.to_json)
    end
  end

  def as_json(options = {})
    {
      current_play: Jukebox.current_play,
      playlist:     Jukebox.queue,
      volume:       Jukebox.volume
    }
  end
end
