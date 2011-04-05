class Jukebox < Ohm::Model
  list      :played,   Song
  reference :current,  Song
  list      :upcoming, Song

  def to_hash
    super.merge :current => current
  end

  def self.app    # TODO: hack for the meantime until multiple jukebox support
    self.all.first || self.create
  end

  def skip!
    if upcoming.empty?
      self.current = nil
    else
      played << self.current if self.current   # add current song to played list
      self.current = upcoming.shift            # pull next song from queue
    end

    save

    # notify clients
    Ohm.redis.publish(Warble::Application.config.pubsub_channel, {
      event:   'skip',
      jukebox: Jukebox.app   # TODO: send removing song and client should validate, if wrong, refetch whole queue
    }.to_json)
  end

  def add_song(song, user)            # TODO: ensure transactional
    song.lovers << user               # assume user adding to queue loves it
    upcoming << song                  # add song to end of queue

    # notify clients of new song
    Ohm.redis.publish(Warble::Application.config.pubsub_channel, {
      event: 'add',
      song:   song
    }.to_json)

    skip! if self.current.nil?        # pick next song if nothing playing
  end
end
