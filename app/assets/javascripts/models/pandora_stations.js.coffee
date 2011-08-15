class Warble.PandoraStation extends Backbone.Model
  initialize: ->
    @songs = new Warble.PandoraSongList
    @songs.url = "/pandora/stations/#{@id}/songs"
    @songs.station = this

class Warble.PandoraStationList extends Backbone.Collection
  model: Warble.PandoraStation
  url: '/pandora/stations'
