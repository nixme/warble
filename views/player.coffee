jQuery(document).ready ($) ->

  class Song extends Backbone.Model
    url: '/app/current'


  class SongPlayerView extends Backbone.View
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
      c = @model.toJSON()
      if c.source != 'pandora'
        # need to kill the current player in case of skip
        $(@el).html ''
      else
        $(@el).html @template current: c
        this.$('audio').bind 'canplay', -> this.play()  # chrome 10 bug workaround: autoplay on <audio> doesn't work
        this.$('audio').bind 'ended', @finished   # ended doesn't bubble so backbone can't handle it

    finished: ->
      $.post '/player/skip'


  class YoutubePlayerView extends Backbone.View
    el: $('#ytplayer_wrapper')

    initialize: ->
      _.bindAll this, 'render', 'finished'
      @model.bind 'change', @render

      # youtube apis make you do this global function junk
      window.handleYoutubeStateChange = (state) =>
        # done playing
        if state == 0
          @finished()

      window.handleYoutubeError = (code) =>
        @finished()

      window.onYouTubePlayerReady = () =>
        @player = document.getElementById 'ytplayer'
        @player.addEventListener 'onStateChange', 'handleYoutubeStateChange'
        @player.addEventListener 'onError', 'handleYoutubeError'
        
      params = 
        allowScriptAccess: 'always'
      atts = 
        id: 'ytplayer'
      window.swfobject.embedSWF 'http://www.youtube.com/apiplayer?version=3&enablejsapi=1&playerapiid=ytplayer', 'ytplayer', '100%', '100%', '8', null, null, params, atts

    render: ->
      # make sure the slow-ass widget has loaded
      if !@player
        window.setTimeout () =>
          this.render()
        , 500
      else
        c = @model.toJSON()
        @player.stopVideo()
        if c.source == 'youtube'
          $('#ytplayer_wrapper').removeClass 'stowed'
          @player.loadVideoById c.youtube_id
        else
          $('#ytplayer_wrapper').addClass 'stowed'

    finished: ->
      $.post '/player/skip'
        
 
  window.song = new Song
  window.songPlayer = new SongPlayerView model: window.song
  window.youtubePlayer = new YoutubePlayerView model: window.song

  window.song.fetch()   # load current song to play

  socket = new io.Socket null,
    port: 8080
    rememberTransport: false
  socket.connect()
  socket.on 'message', (raw_data) ->
    data = JSON.parse(raw_data)
    switch data.event
      when 'skip'
        window.song.set data.jukebox.current
      when 'reload'
        window.location.reload true
