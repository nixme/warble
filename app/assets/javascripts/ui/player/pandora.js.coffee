#= require templates/player_song

class Warble.PandoraPlayerView extends Backbone.View
  DEFAULT_VOLUME = 80

  el: '#player'
  template: window.JST['templates/player_song']

  initialize: ->
    @model.current_play.bind 'change:id', @render, this
    @model.bind 'change:volume', @volume, this

  render: ->
    if @model.current_play.get('song')?.source == 'youtube'
      # need to kill the current player in case of skip
      @$el.html ''
    else   # pandora or hypem or rdio
      vol = @model.get('volume')
      @$el.html @template
        current: @model.current_play.get('song')
      @$('audio').bind 'canplay', ->
        @volume = (vol ? DEFAULT_VOLUME) / 100
        @play()  # chrome 10 bug workaround: autoplay on <audio> doesn't work
      @$('audio').bind 'ended', @finished   # ended doesn't bubble so backbone can't handle it

  volume: ->
    value = @model.get('volume') / 100
    @$('audio').each -> @volume = value

  finished: ->
    @trigger 'song:finished'
