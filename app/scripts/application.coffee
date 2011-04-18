unless console?
  console = {
    log: (arg) ->
      false
    warn: (arg) ->
      false
  }
  
jQuery(document).ready ($) ->     
  class WorkspaceController extends Backbone.Controller
    routes:
      ''                            : 'index'
      '!/'                          : 'home'
      '!/search/:query'             : 'search'
      '!/pandora/stations'          : 'pandoraStations'
      '!/pandora/stations/:id'      : 'pandoraSongs'
      '!/youtube'                   : 'youtube'
      '!/hype'                      : 'hypeChooser'
      '!/hype/latest/:page'         : 'hypeLatest'
      '!/hype/popular/3days/:page'  : 'hypePopular3Days'
      '!/hype/popular/week/:page'   : 'hypePopularWeek'
      '!/hype/:user/:page'          : 'hypeUser'

    initialize: ->
      # initialize models/collections
      @jukebox     = new Jukebox   # TODO: switch to a single song model instead of full jukebox state
      @queue       = new SongList
      @searchView  = new SearchView
      @stationList = new PandoraStationList
      @hypeSongs   = new HypeSongList

      # initialize views
      @currentSongView     = new CurrentSongView model: @jukebox
      @queueView           = new QueueView collection: @queue
      @serviceChooserView  = new ServiceChooserView
      @pandoraAuthView     = new PandoraCredentialsView
      @pandoraStationsView = new PandoraStationsView collection: @stationList
      @youtubeSearchView   = new YoutubeSearchView
      @hypeChooserView     = new HypeFeedsView
      @hypeSongsView       = new HypeSongsView collection: @hypeSongs

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

      if @notify or window.webkitNotifications? is false
        $('a#enable_notifications').hide()

      $('a#enable_notifications').click (event) =>
        if window.webkitNotifications?
          if window.webkitNotifications.checkPermission() == 0
            @notify = true
            $(event.currentTarget).hide()
          else
            window.webkitNotifications.requestPermission =>
              @notify = (window.webkitNotifications.checkPermission() == 0)

        event.preventDefault()

    entitle: (title) ->
      if title
        document.title = "#{title} - warble"
      else
        document.title = "warble"
        
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
    showSpinner: -> 
      console.warn "This command is no longer supported."
    hideSpinner: -> 
      console.warn "This command is no longer supported."
      
    show_spinner_for: (view) -> 
      if view.el.next('.spinner')
        view.el.next('.spinner').show()
      else
        console.warn "No spinner configured for view."
        console.log view.inspect  
    hide_spinner_for: (view) ->
      if view.el.next('.spinner')
        view.el.next('.spinner').fadeOut()
        

    index: ->
      @entitle()
      window.location.hash = '!/'

    home: ->  
      @serviceChooserView.render()

    search: (query) ->
      @entitle "Search"
      #if query?
        # TODO: fill in
      @searchView.render()

    pandoraStations: -> 
      @entitle 'Pandora'
      @show_spinner_for @pandoraStationsView
      @stationList.fetch
        success: =>
          @pandoraStationsView.render()
          @hide_spinner_for @pandoraStationsView
        error: =>
          @pandoraAuthView.render()
          @hide_spinner_for @pandoraStationsView

    pandoraSongs: (id) ->  
      @entitle 'Pandora'
      station = @stationList.get(id)
      if not station?   # can happen on page load directly to here, TODO: doesn't work
        @stationList.fetch()
        station = @stationList.get(id)

      if station?
        @showSpinner()
        station.songs.fetch
          success: =>
            (new PandoraSongsView { model: station }).render()
            @hideSpinner()
          error: =>
            window.location.hash = '!/pandora/stations'
      else  # redirect back to station list
        window.location.hash = '!/pandora/stations'

    youtube: ->
      @entitle 'Pandora'
      @youtubeSearchView.render()

    hypeChooser: ->
      @entitle 'HypeM'
      @hypeChooserView.render()


    # TODO: dry up these hype view flows

    hypeLatest: (page = 1) ->
      @showSpinner()
      @hypeSongs.feed = 'Latest'
      @hypeSongs.url = "/hype?feed=latest&page=#{encodeURIComponent(page)}"
      @hypeSongs.fetch()

    hypePopular3Days: (page = 1) ->
      @showSpinner()
      @hypeSongs.feed = 'Popular - Last 3 Days'
      @hypeSongs.url = "/hype?feed=popular&time=3days&page=#{encodeURIComponent(page)}"
      @hypeSongs.fetch()

    hypePopularWeek: (page = 1) ->
      @showSpinner()
      @hypeSongs.feed = 'Popular - Last Week'
      @hypeSongs.url = "/hype?feed=popular&time=week&page=#{encodeURIComponent(page)}"
      @hypeSongs.fetch()

    hypeUser: (user, page = 1) ->
      @showSpinner()
      @hypeSongs.feed = "#{user}'s Songs"
      @hypeSongs.url = "/hype?username=#{encodeURIComponent(user)}&page=#{encodeURIComponent(page)}"
      @hypeSongs.fetch()


  window.workspace = new WorkspaceController
  Backbone.history.start()
  


  socket = new io.Socket null,
    port: 8765
    rememberTransport: false
  socket.connect()
  socket.on 'message', (raw_data) ->
    data = JSON.parse(raw_data)
    switch data.event
      when 'refresh'
        window.workspace.queue.refresh data.songs
      when 'skip'
        window.workspace.skip data.jukebox
      when 'reload'
        window.location.reload true

  images = [
      'reyes.jpg'
      'brokeh.jpg'
      'universe.jpg'
      'pittsburgh.jpg'
      'goldengate.jpg'
    ]

  $.backstretch("/images/#{images[Math.floor(Math.random() * ((images.length - 1) - 0 + 1) + 0)]}", {speed: 150});
  $.mapKey 'enter', ->
    # TODO: pull up drawer and set focus to search
    console.log 'Enter key pressed'
