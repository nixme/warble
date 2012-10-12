#= require swfobject
#= require jquery.rdio

class Warble.RdioPlayerView extends Backbone.View
  el: '#rdioplayer_wrapper'

  initialize: ->
    @model.current_play.bind 'change:id', @render, this
    @model.bind 'change:volume', @volume, this

    @loaded = false   # TODO: replace with view event, same with youtube
    @player = $('#rdioplayer').rdio(window.rdio_playback_token)
    @player.on('ready.rdio', playerReady)
           .on('playStateChanged.rdio', playerStateChanged)
           .on('positionChanged.rdio', positionChanged)

  render: ->
    if !@loaded
      window.setTimeout (=> @render()), 500
    if @model.current_play.get('song')?.source == 'rdio'
      @$('#rdioplayer').css('visibility', 'visible')
      @player.play(@model.current_play.get('song').external_id)
    else
      @$('#rdioplayer').css('visibility', 'hidden')
    this

  volume: ->
    # @player.setVolume(@model.get('volume') / 100)

  playerReady: =>
    @loaded = true

  playerStateChanged: (event, playState) =>
    alert(playState)

  positionChanged: (event, position) =>
    console.log position