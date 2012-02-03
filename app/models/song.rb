class Song < ActiveRecord::Base
  validate :source,      presence: true
  validate :external_id, presence: true
  validate :title,       presence: true

  belongs_to :user
  has_many   :votes
  has_many   :plays
  has_many   :users_who_voted,  through: :votes, source: :user
  has_many   :users_who_played, through: :plays, source: :user

  # TODO: search indexing stuff

  def self.find_or_create_from_pandora_song(pandora_song, submitter)
    if song = where(source: 'pandora').where(external_id: pandora_song.music_id).first
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
      Resque.enqueue(::ArchiveSong, song.id)  # send for async download
      song
    end
  end

  def self.find_or_create_from_youtube_params(params, submitter)
    if song = where(source: 'youtube').where(external_id: params[:youtube_id]).first
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

  def self.find_or_create_from_hype_song(hype_song, submitter)
    if song = where(source: 'hypem').where(external_id: hype_song.id).first
      song
    else
      song = Song.create({
        source:      'hypem',
        title:       hype_song.title,
        artist:      hype_song.artist,
        url:         hype_song.url,
        external_id: hype_song.id,
        user:        submitter
      })
      Resque.enqueue(::ArchiveSong, song.id)  # send for async download
      song
    end
  end


  def as_json(options = {})
    {
      id:          id,
      source:      source,
      title:       title,
      artist:      artist,
      album:       album,
      cover_url:   cover_url,
      url:         url,
      external_id: external_id,
      user:        user,
      voters:      users_who_voted.as_json
      # TODO: add collection of likes
    }
  end
end
