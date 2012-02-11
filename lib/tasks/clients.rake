namespace :clients do
  desc 'Send a refresh event to all connected clients to reload the app'
  task :refresh => :environment do
    Jukebox.publish_event 'reload'
  end
end
