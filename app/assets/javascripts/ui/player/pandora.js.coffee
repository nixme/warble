#= require templates/player_song

class Warble.PandoraPlayerView extends Backbone.View
  DEFAULT_VOLUME = 80

  template: window.JST['templates/player_song']

  initialize: ->
    @el = $('#player')
    @model.bind 'change:current', @render, this
    @model.bind 'change:volume', @volume, this

  render: ->
    if @model.current_song()?.source == 'youtube'
      # need to kill the current player in case of skip
      @el.html ''
    else   # pandora or hypem
      vol = @model.get('volume')
      @el.html @template
        current: @model.current_song()
      @$('audio').bind 'canplay', ->
        @volume = (vol ? DEFAULT_VOLUME) / 100
        @play()  # chrome 10 bug workaround: autoplay on <audio> doesn't work
      @$('audio').bind 'ended', @finished   # ended doesn't bubble so backbone can't handle it

  volume: ->
    audio = @$('audio')
    if audio.size
      audio.attr 'volume', @model.get('volume') / 100

  finished: ->
    $.post '/jukebox/skip'
