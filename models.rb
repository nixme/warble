class User < Ohm::Model
  attribute :google_id
  attribute :token   # for authenticating websocket client since cookies won't pass
  attribute :first_name
  attribute :last_name
  attribute :email
  #attribute :domain
  attribute :photo_url
  attribute :pandora_username
  attribute :pandora_password

  index :google_id

  collection :songs, Song   # songs the user has added

  def validations
    assert_unique :google_id
  end

  def self.find_or_create_by_google_auth(access_token)
    if user = find(:google_id => access_token['uid']).first
      user
    else   # no user found so create one!
      user_info = access_token['user_info']
      User.create :first_name => user_info['first_name'],
                  :last_name  => user_info['last_name'],
                  :email      => user_info['email'],
                  :token      => SecureRandom.hex(10),
                  :google_id  => access_token['uid']
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def pandora_credentials?
    pandora_username && pandora_password
  end

  def pandora_client
    @pandora ||= Warble::Pandora::Client.new(pandora_username, pandora_password)
  end

  def to_hash
    super.merge :first_name => first_name,
                :last_name  => last_name,
                :email      => email,
                :photo_url  => photo_url,
  end
end

class Song < Ohm::Model
  attribute :source
  attribute :title
  attribute :artist
  attribute :album
  attribute :cover_url
  attribute :url          # url if appropriate for source
  attribute :local_path   # path if downloaded
  attribute :pandora_id   # id for pandora songs
  reference :user, User   # user who added the song
  set :lovers, User       # users who liked the song
  set :haters, User       # users who disliked the song

  index :pandora_id

  def self.from_pandora_song(pandora_song)
    Song.new({
      source:     'pandora',
      title:      pandora_song.title,
      artist:     pandora_song.artist,
      album:      pandora_song.album,
      cover_url:  pandora_song.art_url || pandora_song.artist_art_url,
      url:        pandora_song.audio_url,
      pandora_id: pandora_song.music_id
    })
  end

  def to_hash
    super.merge :source     => source,
                :title      => title,
                :artist     => artist,
                :album      => album,
                :cover_url  => cover_url,
                :url        => url,
                :local_path => local_path,
                :pandora_id => pandora_id,
                :user       => user,
                :lovers     => lovers.all,
                :haters     => haters.all
  end
end

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
    $redis.publish(PUBSUB_CHANNEL, {
      event:   'skip',
      jukebox: Jukebox.app   # TODO: send removing song and client should validate, if wrong, refetch whole queue
    }.to_json)
  end

  def add_song(song)                  # TODO: ensure transactional
    upcoming << song                  # add song to end of queue

    # notify clients of new song
    $redis.publish(PUBSUB_CHANNEL, {
      event: 'add',
      song:   song
    }.to_json)

    skip! if self.current.nil?        # pick next song if nothing playing
  end
end