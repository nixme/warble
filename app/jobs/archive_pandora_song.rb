class ArchivePandoraSong
  @queue = :download

  def self.perform(song_id)
    song = Song[song_id]
    if song
      filename = Rails.root.join('public', 'songs', "#{song_id}.mp3")
      Curl::Easy.download(song.url, filename)   # download the song to disk
      song.url = "/songs/#{song_id}.mp3"        # change location to local path
      song.save
    end
  end
end
