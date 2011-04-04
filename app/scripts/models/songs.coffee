class Song extends Backbone.Model

class SongList extends Backbone.Collection
  model: Song
  url: '/jukebox/songs'
