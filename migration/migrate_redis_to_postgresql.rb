
require 'rubygems'
require 'bundler/setup'
Bundler.require
require 'yaml'


### ----------------------------- OLD OHM MODELS -------------------------------

class User < Ohm::Model
  attribute :facebook_id
  attribute :token   # for authenticating websocket client since cookies won't pass
  attribute :first_name
  attribute :last_name
  attribute :email
  attribute :photo_url
  attribute :pandora_username
  attribute :pandora_password
  attribute :num_songs_queued_today
  attribute :date_last_queued

  index :facebook_id
end

class Song < Ohm::Model
  attribute :source
  attribute :title
  attribute :artist
  attribute :album
  attribute :cover_url
  attribute :url          # url if appropriate for source
  attribute :external_id  # external (youtube, pandora) id
  reference :user, User   # user who found the song (not necessarily added it)
  counter   :hits         # number of times this song was processed
  counter   :plays        # number of times this song was played
  set :lovers, User       # users who liked the song
  set :haters, User       # users who disliked the song

  index :external_id
end

class Jukebox < Ohm::Model
  list      :played,   Song
  reference :current,  Song
  attribute :volume
end



### --------------------------- NEW POSGTRES MODELS ----------------------------

pg_config = YAML::load(File.open('../config/database.yml'))
ActiveRecord::Base.establish_connection(pg_config['development'])    # TODO

module Relational
  class User < ActiveRecord::Base
    has_many :songs
    has_many :votes
    has_many :plays
  end

  class Play < ActiveRecord::Base
    belongs_to :user
    belongs_to :song
  end

  class Song < ActiveRecord::Base
    belongs_to :user
    has_many   :votes
    has_many   :plays
  end

  class Vote < ActiveRecord::Base
    belongs_to :user
    belongs_to :song
  end
end


### ------------------------------ DATA MIGRATION ------------------------------

puts 'Starting migration'

puts '  Migrating users...'
users = {}     # Simple identity map of users
User.all.each do |user|
  new_user = Relational::User.new(
    facebook_id:      user.facebook_id,
    first_name:       user.first_name,
    last_name:        user.last_name,
    email:            user.email,
    photo_url:        user.photo_url,
    pandora_username: user.pandora_username,
    pandora_password: user.pandora_password
  )
  new_user.id = user.id   # Manually setting the ID on create/new doesn't work.
  new_user.save

  users[new_user.id] = new_user
end

puts '  Migrating songs...'
count = 0
Song.all.each do |song|
  next unless song.external_id && song.title

  new_song = Relational::Song.new(
    source:      song.source,
    external_id: song.external_id,
    title:       song.title,
    artist:      song.artist,
    album:       song.album,
    cover_url:   song.cover_url,
    url:         song.url,
    user_id:     song.user_id
  )
  new_song.id = song.id

  begin
    new_song.save
  rescue ActiveRecord::RecordNotUnique
    # Skip songs with the same source and external_id
    next
  end

  # Record all song lovers as user plays
  song.lovers.each do |lover|
    user = users[lover.id]
    new_song.plays.create(user: user)
  end

  count +=1
  puts "    #{count} songs migrated" if count % 1000 == 0
end

# All past plays don't have a timestamp so make them NULL
Relational::Play.update_all created_at: nil

puts '  Adjusting primary key sequences...'
ActiveRecord::Base.connection.execute <<SQL
  ALTER SEQUENCE users_id_seq RESTART WITH #{Relational::User.maximum(:id) + 1};
  ALTER SEQUENCE songs_id_seq RESTART WITH #{Relational::Song.maximum(:id) + 1};
SQL

puts 'Finished migration'
