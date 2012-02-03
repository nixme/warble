require 'fileutils'

class ArchiveSong
  @queue = :download

  def self.perform(song_id)
    song = Song.find(song_id)
    if song
      raise "No URL!" unless song.url    # check for an actual URL
      filename = Rails.root.join('public', 'songs', "#{song_id}.mp3").to_s

      # download the song to disk
      http = Patron::Session.new
      http.connect_timeout = 2
      http.timeout = 500
      http.get_file(song.url, filename)

      # check that it actually downloaded
      if !File.size?(filename)
        FileUtils.rm(filename, :force => true)
        raise "Song didn't download!"
      end

      # change location to local path
      song.url = "/songs/#{song_id}.mp3"
      song.save
    end
  end
end
