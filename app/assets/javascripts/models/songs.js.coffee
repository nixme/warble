class Warble.Song extends Backbone.Model

class Warble.SongList extends Backbone.Collection
  model: Warble.Song
  url: '/jukebox/songs'

class Warble.SearchList extends Backbone.Collection
  model: Warble.Song
  url: ->
    if @query?
      "/jukebox/search?query=#{encodeURIComponent(@query)}"
    else
      "/jukebox/search"
