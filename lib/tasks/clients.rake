namespace :clients do
  desc 'Send a refresh event to all connected clients to reload the app'
  task :refresh => :environment do
    Ohm.redis.publish(Warble::Application.config.pubsub_channel, {
      event: 'reload'
    }.to_json)
  end
end
