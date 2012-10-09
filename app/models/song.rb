require 'fileutils'

class Song < ActiveRecord::Base
  include Tire::Model::Search

  validate :source,      presence: true
  validate :external_id, presence: true
  validate :title,       presence: true

  belongs_to :user
  has_many   :votes
  has_many   :plays
  has_many   :users_who_voted,  through: :votes, source: :user
  has_many   :users_who_played, through: :plays, source: :user

  tire.mapping do
    indexes :id,     type: :integer, index: :not_analyzed
    indexes :title,  type: :string,  analyzer: :snowball,  boost: 3
    indexes :artist, type: :string,  analyzer: :snowball,  boost: 2
    indexes :album,  type: :string,  analyzer: :snowball,  boost: 2
    indexes :source, type: :string,  index: :not_analyzed, boost: 0.1
  end

  after_commit ->(song) { IndexSongWorker.perform_async song.id }  # Index after any saves


  def self.find_or_create_from_pandora_song(pandora_song, submitter)
    if song = where(source: 'pandora').where(external_id: pandora_song.id).first
      song.fsck! pandora_song.audio_url
      song
    else   # first time seeing the song, so create it
      song = Song.create({
        source:      'pandora',
        title:       pandora_song.title,
        artist:      pandora_song.artist,
        album:       pandora_song.album,
        cover_url:   pandora_song.album_art_url,
        url:         pandora_song.audio_url,
        external_id: pandora_song.id,
        user:        submitter
      }, without_protection: true)
      ArchiveSongWorker.perform_async song.id   # Queue for archiving
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
      }, without_protection: true)
    end
  end

  def self.find_or_create_from_hype_song(hype_song, submitter)
    if song = where(source: 'hypem').where(external_id: hype_song.id).first
      song.fsck! hype_song.url
      song
    else
      song = Song.create({
        source:      'hypem',
        title:       hype_song.title,
        artist:      hype_song.artist,
        url:         hype_song.url,
        external_id: hype_song.id,
        user:        submitter
      }, without_protection: true)
      ArchiveSongWorker.perform_async song.id   # Queue for archiving
      song
    end
  end

  def self.random
    # 7 out of 10 times we'll play something from the rotation, else we'll just pick something completely random
    if rand(10) > 5
      # Take the last 1000 plays but rid duplicate songs
      song_ids = Play.where('user_id IS NOT NULL')
                     .order('created_at DESC NULLS LAST')
                     .limit(1000).map(&:song_id).uniq

      # Join to votes to influence randomness. Each song starts with 1 point.
      # Each vote adds 2 points to the song.
      song_id_to_votes = Hash[
        Vote.select('song_id, count(*) AS votes')
            .group(:song_id)
            .where(song_id: song_ids)
            .map { |row| [row.song_id, [row.song_id] + ([row.song_id] * row.votes.to_i * 2)] }
      ]

      random_song_id = song_ids.each do |song_id|
        song_id_to_votes[song_id] || [song_id]
      end.flatten.sample

      find random_song_id
    else
      find(:first, :offset =>rand(count))
    end
  end

  # Is this song archivable to disk?
  def archivable?
    %w[pandora hypem].include?(source)
  end

  # Ensure a song has been archived.
  #
  # Occassionally a song may not get archived if a job or net fails. Then it's
  # forever broken if the URL relied on a one-time token. If we come across the
  # song again with a new URL, then try archiving again.
  def fsck!(new_url)
    return unless archivable?

    unless url =~ %r{^/songs/}  # Unarchived song?
      self.url = new_url        # Then use the new URL and
      save!                     #   queue for re-archiving
      ArchiveSongWorker.perform_async id
    end
  end

  def archive!
    raise "Cannot archive a #{source} song" unless archivable?
    raise 'No URL!' unless url    # Check for an actual URL
    filename = Rails.root.join('public', 'songs', "#{id}.mp3").to_s

    # Archive the song to disk
    http = Patron::Session.new
    http.connect_timeout = 2
    http.timeout = 500
    http.get_file(url, filename)

    # Check that it actually saved
    if !File.size?(filename)
      FileUtils.rm filename, force: true
      raise 'Error archiving song'
    end

    # Change location to local path
    self.url = "/songs/#{id}.mp3"
    save!
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
      votes:       votes.as_json,
      voters:      users_who_voted.as_json
      # TODO: add collection of likes
    }
  end
end
