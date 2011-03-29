jQuery(document).ready ($) ->

  class Song extends Backbone.Model
    url: '/app/current'


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
      $(@el).html @template current: @model.toJSON()
      this.$('audio').bind 'canplay', -> this.play()  # chrome 10 bug workaround: autoplay on <audio> doesn't work
      this.$('audio').bind 'ended', @finished   # ended doesn't bubble so backbone can't handle it

    finished: ->
      $.post '/player/skip'


  window.song = new Song
  window.player = new PlayerView model: window.song

  window.song.fetch()   # load current song to play

  socket = new io.Socket 'localhost',
    port: 8080
    rememberTransport: false
  socket.connect()
  socket.on 'message', (raw_data) ->
    data = JSON.parse(raw_data)
    switch data.event
      when 'skip'
        window.song.set data.jukebox.current
