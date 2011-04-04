class Song < Ohm::Model
  attribute :source
  attribute :title
  attribute :artist
  attribute :album
  attribute :cover_url
  attribute :url          # url if appropriate for source
  attribute :local_path   # path if downloaded
  attribute :pandora_id   # id for pandora songs
  attribute :youtube_id   # TODO: combine with pandora id?
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

  # TODO fix this up to use api to get video metadata
  def self.from_youtube_params(params)
    #query = Addressable::URI::parse(youtube_url).query_values
    Song.new({
      source:     'youtube',
      title:      params[:title],
      artist:     params[:author],
      cover_url:  params[:thumbnail],
      youtube_id: params[:youtube_id]
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
                :youtube_id => youtube_id,
                :user       => user,
                :lovers     => lovers.all,
                :haters     => haters.all
  end
end
