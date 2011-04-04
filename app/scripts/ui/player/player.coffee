class PlayerView extends Backbone.View
  template: window.templates['song']

  initialize: ->
    _.bindAll this, 'render', 'finished'
    @el = $('#player')
    @model.bind 'change', @render

  render: ->
    $(@el).html @template current: @model.get('current')
    this.$('audio').bind 'canplay', -> this.play()  # chrome 10 bug workaround: autoplay on <audio> doesn't work
    this.$('audio').bind 'ended', @finished   # ended doesn't bubble so backbone can't handle it

  finished: ->
    $.post '/player/skip'
