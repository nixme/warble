class Jukebox < ActiveRecord::Base
  has_many :songs, through: :plays


  def volume
    $redis_pool.with { |redis| redis.get(scoped_key('volume')).to_i }
  end

  def volume=(value)
    $redis_pool.with { |redis| redis.set(scoped_key('volume'), value.to_i) }
    publish_change_event
  end

  def current_play
    play_id = $redis_pool.with { |redis| redis.get(scoped_key('current_play')) }
    Play.find_by_id(play_id)
  end

  def current_song
    current_play.song
  end

  def queue
    $redis_pool.with do |redis|
      redis.zrange(scoped_key('queue'), 0, -1)
        .map { |play_id| Play.find_by_id(play_id) }
        .compact
    end
  end

  def enqueue(song, user = nil)
    # TODO: This needs to be jukebox-scoped
    priority = user ? user.number_of_plays_today : 999

    play = Play.new
    play.user = user
    play.song = song
    play.save!

    $redis_pool.with { |redis| redis.zadd(scoped_key('queue'), priority, play.id) }

    # publish_change_event

    skip unless current_play
  end

  def skip
    $redis_pool.with do |redis|
      if redis.zcard(scoped_key('queue')) == 0      # If nothing queued
        redis.del(scoped_key('current_play'))       # ...then kill current song
        enqueue Song.random                         # ...and auto-queue another song
      else
        results = redis.multi do                    # Pop from queue and set as current
          redis.zrange(scoped_key('queue'), 0, 0)
          redis.zremrangebyrank(scoped_key('queue'), 0, 0)
        end
        redis.set(scoped_key('current_play'), results.first.first)
      end
    end

    # FIXME @nixme
    # publish_change_event
  end

 private

  def scoped_key(key)
    "warble:jukebox_#{self.id}:#{key}"
  end

  # TODO: Make this work.
  def publish_change_event
    PushMessageWorker.message(
      event:   'jukebox:change',
      jukebox: as_json
    )
  end

end
