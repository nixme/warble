# Worker to index songs in ElasticSearch via tire
#
class IndexSongWorker
  include Sidekiq::Worker

  sidekiq_options queue: :indexing

  def perform(song_id)
    song = Song.find_by_id(song_id)
    song.update_index if song
  end
end
