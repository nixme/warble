class Warble.PartySong extends Backbone.Model

class Warble.PartySongList extends Backbone.Collection
  model: Warble.PartySong

  availableFields: [ 'artist', 'title' ]
  field: 'artist'

  url: ->
    "/party/songs?query=#{encodeURIComponent(@query)}"
