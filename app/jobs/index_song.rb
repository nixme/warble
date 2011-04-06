class IndexSong
  @queue = :index

  def self.perform(song_id)
    song = Song[song_id]
    Sunspot.index!(song) if song   # index song into Solr via sunspot
  end
end
