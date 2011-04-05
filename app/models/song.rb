class Song < Ohm::Model
  attribute :source
  attribute :title
  attribute :artist
  attribute :album
  attribute :cover_url
  attribute :url          # url if appropriate for source
  attribute :external_id  # external (youtube, pandora) id
  reference :user, User   # user who found the song (not necessarily added it)
  counter   :hits         # number of times this song was processed
  set :lovers, User       # users who liked the song
  set :haters, User       # users who disliked the song

  index :external_id

  def self.find_or_create_from_pandora_song(pandora_song, submitter)
    if song = find(:external_id => pandora_song.music_id).first
      song.incr :hits
      song
    else   # first time seeing the song, so create it
      song = Song.create({
        source:      'pandora',
        title:       pandora_song.title,
        artist:      pandora_song.artist,
        album:       pandora_song.album,
        cover_url:   pandora_song.art_url || pandora_song.artist_art_url,
        url:         pandora_song.audio_url,
        external_id: pandora_song.music_id,
        user:        submitter
      })
      Resque.enqueue(::ArchivePandoraSong, song.id)  # send for async download
      song
    end
  end

  def self.find_or_create_from_youtube_params(params, submitter)
    if song = find(:external_id => params[:youtube_id]).first
      song.incr :hits
      song
    else
      Song.create({
        source:      'youtube',
        title:       params[:title],
        artist:      params[:author],
        cover_url:   params[:thumbnail],
        external_id: params[:youtube_id],
        user:        submitter
      })
    end
  end

  def to_hash
    super.merge :source      => source,
                :title       => title,
                :artist      => artist,
                :album       => album,
                :cover_url   => cover_url,
                :url         => url,
                :external_id => external_id,
                :user        => user,
                :lovers      => lovers.all,
                :haters      => haters.all
  end
end
