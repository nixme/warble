class IndexSong
  @queue = :index

  def self.perform(song_id)
    song = Song[song_id]
    Sunspot.index!(song) if Song   # index song into Solr via sunspot
  end
end
