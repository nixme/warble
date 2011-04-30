class PandoraPlayerView extends Backbone.View
  DEFAULT_VOLUME = 80

  template: -> window.templates['song']

  initialize: ->
    _.bindAll this, 'render', 'volume', 'finished'
    @el = $('#player')
    @model.bind 'change:current', @render
    @model.bind 'change:volume', @volume

  render: ->
    if @model.current_song()?.source == 'youtube'
      # need to kill the current player in case of skip
      @el.html ''
    else   # pandora or hypem
      vol = @model.get('volume')
      @el.html this.template() 
        current: @model.current_song()
      this.$('audio').bind 'canplay', -> 
        this.volume = (vol ? DEFAULT_VOLUME) / 100
        this.play()  # chrome 10 bug workaround: autoplay on <audio> doesn't work
      this.$('audio').bind 'ended', @finished   # ended doesn't bubble so backbone can't handle it

  volume: ->
    audio = @.$('audio')
    if audio.size
      audio.attr 'volume', @model.get('volume') / 100

  finished: ->
    $.post '/jukebox/skip'
