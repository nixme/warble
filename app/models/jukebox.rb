module Jukebox
  extend self

  def volume
    $redis.get('warble:volume').to_i
  end

  def volume=(value)
    $redis.set('warble:volume', value.to_i)
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
end
