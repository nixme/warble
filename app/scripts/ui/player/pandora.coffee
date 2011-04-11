class PandoraPlayerView extends Backbone.View
  template: -> window.templates['song']

  initialize: ->
    _.bindAll this, 'render', 'finished'
    @el = $('#player')
    @model.bind 'change', @render

  render: ->
    if @model.current_song()?.source == 'youtube'
      # need to kill the current player in case of skip
      $(@el).html ''
    else   # pandora or hypem
      $(@el).html this.template() current: @model.current_song()
      this.$('audio').bind 'canplay', -> this.play()  # chrome 10 bug workaround: autoplay on <audio> doesn't work
      this.$('audio').bind 'ended', @finished   # ended doesn't bubble so backbone can't handle it

  finished: ->
    $.post '/jukebox/skip'
