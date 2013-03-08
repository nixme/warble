# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20120203195018) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "plays", force: true do |t|
    t.integer  "user_id"
    t.integer  "song_id",                null: false
    t.datetime "created_at"
    t.integer  "skips",      default: 0, null: false
  end

  add_index "plays", ["song_id", "user_id"], name: "index_plays_on_song_id_and_user_id"

  create_table "songs", force: true do |t|
    t.string   "source",      null: false
    t.string   "external_id", null: false
    t.text     "title",       null: false
    t.text     "artist"
    t.text     "album"
    t.text     "cover_url"
    t.text     "url"
    t.integer  "user_id",     null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "songs", ["source", "external_id"], name: "index_songs_on_source_and_external_id", unique: true

  create_table "users", force: true do |t|
    t.string   "facebook_id",      null: false
    t.string   "first_name",       null: false
    t.string   "last_name",        null: false
    t.string   "email",            null: false
    t.string   "photo_url"
    t.string   "pandora_username"
    t.string   "pandora_password"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "users", ["facebook_id"], name: "index_users_on_facebook_id", unique: true

  create_table "votes", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "song_id",    null: false
    t.datetime "created_at", null: false
  end

  add_index "votes", ["song_id", "user_id"], name: "index_votes_on_song_id_and_user_id", unique: true

end
