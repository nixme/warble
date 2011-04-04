class PandoraStation extends Backbone.Model
  initialize: ->
    @songs = new PandoraSongList
    @songs.url = "/pandora/stations/#{@id}/songs"
    @songs.station = this

class PandoraStationList extends Backbone.Collection
  model: PandoraStation
  url: '/pandora/stations'
