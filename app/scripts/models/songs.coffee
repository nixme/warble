class Song extends Backbone.Model

class SongList extends Backbone.Collection
  model: Song
  url: '/jukebox/songs'

class SearchList extends Backbone.Collection
  model: Song
  url: ->
    if @query?
      "/jukebox/search?query=#{encodeURIComponent(@query)}"
    else
      "/jukebox/search"
