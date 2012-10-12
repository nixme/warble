#= require swfobject
#= require jquery.rdio

class Warble.RdioPlayerView extends Backbone.View
  el: '#rdioplayer_wrapper'

  initialize: ->
    @model.current_play.bind 'change:id', @render, this
    @model.bind 'change:volume', @volume, this

    @loaded = false   # TODO: replace with view event, same with youtube
    @state = 'stopped'
    $rdioplayer = $('#rdioplayer')
    @player = $rdioplayer.rdio(window.rdio_playback_token)
    $rdioplayer.on('ready.rdio', @playerReady)
               .on('playStateChanged.rdio', @playerStateChanged)
               .on('positionChanged.rdio', @positionChanged)

  render: ->
    return _.delay((=> @render()), 500) unless @loaded

    if @model.current_play.get('song')?.source == 'rdio'
      @player.play(@model.current_play.get('song').external_id)
      @state = 'requested'
    else
      @state = 'stopped'
      @player.stop()
    this

  volume: ->
    return _.delay((=> @volume()), 500) unless @loaded

    @player.setVolume(@model.get('volume') / 100)

  playerReady: (event, userInfo) =>
    @loaded = true
    console.log "ready", userInfo

  playerStateChanged: (event, playState) =>
    console.log "Rdio playStateChanged", playState

    # Rdio SWF sends playState 2 when play is called. Using intermediary state
    # 'requested' to detect it.
    if @state == 'requested' && playState == 1
      @state = 'playing'

    else if @state == 'playing' && playState == 2
      @state = 'stopped'
      @trigger 'song:finished'

    else if playState == 2
      @state = 'stopped'

  positionChanged: (event, position) =>
    # TODO: update position counter when we have one
