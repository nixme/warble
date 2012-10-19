class Warble.RdioPlayerView extends Backbone.View
  el: '#rdioplayer_wrapper'

  initialize: ->
    @model.current_play.bind 'change:id', @render, this
    @model.bind 'change:volume', @volume, this

    @state = 'stopped'

    R.ready =>
      R.player.on 'change:position',  @positionChanged, this
      R.player.on 'change:playState', @playerStateChanged, this

  render: ->
    R.ready =>
      if @model.current_play.get('song')?.source == 'rdio'
        R.player.play source: @model.current_play.get('song').external_id
        @state = 'requested'
      else
        @state = 'stopped'
        R.player.pause()
    this

  volume: ->
    R.ready =>
      R.player.volume(@model.get('volume') / 100)

  playerStateChanged: (playState) ->
    console.log "Rdio playStateChanged", playState

    # Rdio component sends PLAYSTATE_STOPPED when play is called for the first
    # time. Using intermediary state 'requested' to detect so we don't trigger
    # 'song:finished' prematurely.

    if @state == 'requested' && playState == R.player.PLAYSTATE_PLAYING
      @state = 'playing'

    else if @state == 'playing' && playState == R.player.PLAYSTATE_STOPPED
      @state = 'stopped'
      @trigger 'song:finished'

    else if playState == R.player.PLAYSTATE_STOPPED
      @state = 'stopped'

  positionChanged: (position) ->
    # TODO: update position counter when we have one
