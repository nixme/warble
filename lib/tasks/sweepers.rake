require 'fileutils'

namespace :sweepers do
  # The older version of the ArchiveSong job sometimes downloaded incorrectly
  # but didn't fail the job, causing resque to believe it succeeded. This task
  # combs through all songs and deletes incorrectly downloaded ones
  desc 'Remove songs that were incorrectly downloaded'
  task :clean_incorrectly_downloaded_songs => :environment do
    Song.all.each do |song|                        # Check every song in db
      if song.url && song.url =~ /^\/songs/        # If supposedly downloaded
        fullpath = Rails.root.join('public', song.url[1..-1])
        if !File.size?(fullpath)                   # but the file was empty,
          puts "Deleting #{song.title}"
          FileUtils.rm(fullpath, :force => true)   # then delete the file
          song.delete                              #   and the song.
        end
      end
    end
  end
end
