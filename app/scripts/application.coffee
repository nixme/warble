jQuery(document).ready ($) ->
  class WorkspaceController extends Backbone.Controller
    routes:
      ''                       : 'index'
      '!/'                     : 'home'
      '!/pandora/stations'     : 'pandoraStations'
      '!/pandora/stations/:id' : 'pandoraSongs'
      '!/youtube'              : 'youtube'

    initialize: ->
      # initialize app components
      @jukebox = new Jukebox   # TODO: switch to a single song model instead of full jukebox state
      @queue = new SongList
      @stationList = new PandoraStationList
      @currentSongView ||= new CurrentSongView { model: @jukebox }
      @queueView ||= new QueueView { collection: @queue }
      @serviceChooserView ||= new ServiceChooserView
      @pandoraAuthView ||= new PandoraCredentialsView
      @pandoraStationsView ||= new PandoraStationsView { collection: @stationList }
      @youtubeSearchView ||= new YoutubeSearchView

      # load data
      @jukebox.fetch()
      @queue.fetch()
      @stationList.fetch()

      # player buttons. TODO: move to view class
      $('a#forward').click (event) ->
        $.post '/jukebox/skip'
        event.preventDefault()

      # notification button. TODO: move to a view class
      @notify = (window.webkitNotifications?.checkPermission() == 0)
      $('a#settings').click (event) =>
        if window.webkitNotifications?
          if window.webkitNotifications.checkPermission() == 0
            @notify = true
          else
            window.webkitNotifications.requestPermission =>
              @notify = (window.webkitNotifications.checkPermission() == 0)
        event.preventDefault()

    skip: (jukebox) ->
      @jukebox.set jukebox              # update current song
      promoted_song = @queue.at(0)
      if promoted_song?
        @queue.remove(promoted_song)    # remove top song in queue
      else
        @queue.fetch()                  # refetch in case of error

      if @notify
        song = jukebox.current
        notification = window.webkitNotifications.createNotification(song.cover_url, song.artist, song.title)
        notification.ondisplay = ->
          setTimeout (-> notification.cancel()), 5000
        notification.show()

    # TODO: move to the proper single #app view
    showSpinner: -> $('#spinner').fadeIn()
    hideSpinner: -> $('#spinner').fadeOut()

    index: ->
      window.location.hash = '!/'

    home: ->
      @serviceChooserView.render()

    pandoraStations: ->
      this.showSpinner()
      @stationList.fetch
        success: =>
          @pandoraStationsView.render()
          this.hideSpinner()
        error: =>
          @pandoraAuthView.render()
          this.hideSpinner()

    pandoraSongs: (id) ->
      station = @stationList.get(id)
      if not station?   # can happen on page load directly to here, TODO: doesn't work
        @stationList.fetch()
        station = @stationList.get(id)

      if station?
        this.showSpinner()
        station.songs.fetch
          success: =>
            (new PandoraSongsView { model: station }).render()
            this.hideSpinner()
          error: =>
            window.location.hash = '!/pandora/stations'
      else  # redirect back to station list
        window.location.hash = '!/pandora/stations'

    youtube: ->
      @youtubeSearchView.render()

  window.workspace = new WorkspaceController
  Backbone.history.start()



  socket = new io.Socket null,
    port: 8080
    rememberTransport: false
  socket.connect()
  socket.on 'message', (raw_data) ->
    data = JSON.parse(raw_data)
    switch data.event
      when 'add'
        window.workspace.queue.add data.song
      when 'skip'
        window.workspace.skip data.jukebox
      when 'reload'
        window.location.reload true

  $.mapKey 'enter', ->
    # TODO: pull up drawer and set focus to search
    console.log 'Enter key pressed'
