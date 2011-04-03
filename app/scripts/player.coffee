jQuery(document).ready ($) ->

  class Jukebox extends Backbone.Model
    url: '/jukebox'


  class PlayerView extends Backbone.View
    el: $('#player')

    template: Handlebars.compile '''
      {{#current}}
        <audio src="{{url}}" type="audio/mp3" autoplay />
        <img id="cover" src="{{cover_url}}" />
        <div id="artist">{{artist}}</div>
        <div id="title">{{title}}</div>
      {{^}}
        <div id="artist">No songs in queue</div>
      {{/current}}
    '''

    initialize: ->
      _.bindAll this, 'render', 'finished'
      @model.bind 'change', @render

    render: ->
      $(@el).html @template current: @model.get('current')
      this.$('audio').bind 'canplay', -> this.play()  # chrome 10 bug workaround: autoplay on <audio> doesn't work
      this.$('audio').bind 'ended', @finished   # ended doesn't bubble so backbone can't handle it

    finished: ->
      $.post '/player/skip'


  window.jukebox = new Jukebox
  window.player = new PlayerView model: window.jukebox

  window.jukebox.fetch()   # load current song to play

  socket = new io.Socket null,
    port: 8080
    rememberTransport: false
  socket.connect()
  socket.on 'message', (raw_data) ->
    data = JSON.parse(raw_data)
    switch data.event
      when 'skip'
        window.jukebox.set data.jukebox
      when 'reload'
        window.location.reload true
