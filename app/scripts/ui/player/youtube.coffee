class YoutubePlayerView extends Backbone.View
  initialize: ->
    _.bindAll this, 'render', 'finished'
    @el = $('#ytplayer_wrapper')
    @model.bind 'change', @render

    # youtube apis make you do this global function junk
    window.handleYoutubeStateChange = (state) =>
      if state == 0  # done playing
        this.finished()

    window.handleYoutubeError = =>
      this.finished()

    window.onYouTubePlayerReady = =>
      @player = document.getElementById 'ytplayer'
      @player.addEventListener 'onStateChange', 'handleYoutubeStateChange'
      @player.addEventListener 'onError', 'handleYoutubeError'

    window.swfobject.embedSWF 'http://www.youtube.com/apiplayer?version=3&enablejsapi=1&playerapiid=ytplayer',
      'ytplayer', '100%', '100%', '8', null, null,
      { allowScriptAccess: 'always'},
      { id: 'ytplayer'}

  render: ->
    if !@player
      # make sure the slow-ass widget has loaded first
      window.setTimeout (=> this.render()), 500
    else
      @player.stopVideo() if @player.stopVideo
      if @model.current_song()?.source == 'youtube'
        this.$('#ytplayer').css('visibility', 'visible')
        @player.loadVideoById @model.current_song().youtube_id
      else
        this.$('#ytplayer').css('visibility', 'hidden')

  finished: ->
    $.post '/jukebox/skip'
