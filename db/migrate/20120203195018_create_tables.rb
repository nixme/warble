class CreateTables < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string     :facebook_id,      null: false
      t.string     :first_name,       null: false
      t.string     :last_name,        null: false
      t.string     :email,            null: false
      t.string     :photo_url
      t.string     :pandora_username
      t.string     :pandora_password
      t.timestamps                    null: false
    end

    add_index :users, :facebook_id, unique: true

    create_table :songs do |t|
      t.string     :source,      null: false
      t.string     :external_id, null: false
      t.string     :title,       null: false
      t.string     :artist
      t.string     :album
      t.text       :cover_url
      t.text       :url
      t.belongs_to :user,        null: false
      t.timestamps               null: false
    end

    add_index :songs, [:source, :external_id], unique: true

    create_table :votes do |t|
      t.belongs_to :user
      t.belongs_to :song,       null: false
      t.datetime   :created_at, null: false
    end

    add_index :votes, [:song_id, :user_id], unique: true

    create_table :plays do |t|
      t.belongs_to :user,       null: false
      t.belongs_to :song,       null: false
      t.datetime   :created_at, null: false
      t.integer    :skips,      null: false, default: 0
    end

    add_index :plays, [:song_id, :user_id], unique: true
  end

  def down
    drop_table :users, :songs, :votes, :plays
  end
end
