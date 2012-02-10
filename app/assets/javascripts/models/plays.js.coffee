class Warble.Play extends Backbone.Model

class Warble.Playlist extends Backbone.Collection
  model: Warble.Play
  url: '/jukebox/playlist'
