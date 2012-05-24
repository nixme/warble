# Worker to archive songs
#
class ArchiveSongWorker
  include Sidekiq::Worker

  sidekiq_options queue: :archiving


  def perform(song_id)
    song = Song.find_by_id(song_id)
    song.archive! if song
  end
end
