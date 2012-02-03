module Jukebox
  extend self

  # TODO: some of these need to be atomic ops

  def volume
    $redis.get('warble:volume').to_i
  end

  def volume=(value)
    $redis.set('warble:volume', value.to_i)
    publish_volume
  end

  def current_play
    Play.find_by_id($redis.get('warble:current_play'))
  end

  def current_song
    play = current_play
    play && play.song
  end

  def queue
    $redis.zrange('warble:queue', 0, -1)
      .map { |play_id| Play.find_by_id(play_id) }
      .compact
  end

  def queue_as_songs
    queue.map(&:song)
  end

  def enqueue(song, user)
    play = user.plays.create(song: song)

    # TODO: do proper priorities
    $redis.zadd('warble:queue', 1, play.id)

    unless current_play
      skip!
    end
  end

  def skip
    if $redis.zcard('warble:queue') == 0
      $redis.del('warble:current_play')
    else
      # TODO
    end

    publish_skip
  end

  def publish_queue_refresh
    $redis.publish(Warble::Application.config.pubsub_channel, {
      event: 'refresh',
      songs: queue_as_songs
    }.to_json)
  end

  def publish_skip
    $redis.publish(Warble::Application.config.pubsub_channel, {
      event: 'skip',
      songs: as_json
    }.to_json)
  end

  def publish_volume
    $redis.publish(Warble::Application.config.pubsub_channel, {
      event: 'volume',
      jukebox: as_json
    }.to_json)
  end

  def as_json(options = {})
    {
      current: Jukebox.current_song,
      volume:  Jukebox.volume
    }
  end
end
