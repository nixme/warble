#= require jquery
#= require jquery-ui
#= require rails/csrf
#= require rails/method
#= require underscore
#= require backbone
#= require jquery.mapkey
#= require tooltip

#= require_self

#= require_tree ./models
#= require_tree ./ui/application

window.Warble = {}  # namespacing object for our classes

jQuery(document).ready ($) ->
  class Warble.WorkspaceController extends Backbone.Router
    routes:
      '/search/:query'             : 'search'
      '/pandora/stations'          : 'pandoraStations'
      '/pandora/stations/:id'      : 'pandoraSongs'
      '/youtube'                   : 'youtube'
      '/hype'                      : 'hypeChooser'
      '/hype/latest/:page'         : 'hypeLatest'
      '/hype/popular/3days/:page'  : 'hypePopular3Days'
      '/hype/popular/week/:page'   : 'hypePopularWeek'
      '/hype/:user/:page'          : 'hypeUser'
      '*unmatched'                 : 'home'

    initialize: ->
      # initialize models/collections
      @jukebox     = new Warble.Jukebox   # TODO: switch to a single song model instead of full jukebox state
      @queue       = new Warble.SongList
      @searchView  = new Warble.SearchView
      @stationList = new Warble.PandoraStationList
      @hypeSongs   = new Warble.HypeSongList

      # initialize views
      @currentSongView     = new Warble.CurrentSongView model: @jukebox
      @queueView           = new Warble.QueueView collection: @queue
      @serviceChooserView  = new Warble.ServiceChooserView
      @pandoraAuthView     = new Warble.PandoraCredentialsView
      @pandoraStationsView = new Warble.PandoraStationsView collection: @stationList
      @youtubeSearchView   = new Warble.YoutubeSearchView
      @hypeChooserView     = new Warble.HypeFeedsView
      @hypeSongsView       = new Warble.HypeSongsView collection: @hypeSongs

      # load data
      @jukebox.fetch()
      @queue.fetch()
      @stationList.fetch()

      # player buttons. TODO: move to view class
      $('a#forward').click (event) ->
        $.post '/jukebox/skip'
        event.preventDefault()

      # volume
      $('#volume').slider
        animate: true
        value: $('#volume').data 'volume'
        stop: (e, ui) ->
          $.ajax '/jukebox/volume'
            type: 'put'
            data:
              value: ui.value

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

    home: ->
      @serviceChooserView.render()

    search: (query) ->
      #if query?
        # TODO: fill in
      @searchView.render()

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
            (new Warble.PandoraSongsView { model: station }).render()
            this.hideSpinner()
          error: =>
            window.workspace.navigate '/pandora/stations', true
      else  # redirect back to station list
        window.workspace.navigate '/pandora/stations', true

    youtube: ->
      @youtubeSearchView.render()

    hypeChooser: ->
      @hypeChooserView.render()


    # TODO: dry up these hype view flows

    hypeLatest: (page = 1) ->
      this.showSpinner()
      @hypeSongs.feed = 'Latest'
      @hypeSongs.url = "/hype?feed=latest&page=#{encodeURIComponent(page)}"
      @hypeSongs.fetch()

    hypePopular3Days: (page = 1) ->
      this.showSpinner()
      @hypeSongs.feed = 'Popular - Last 3 Days'
      @hypeSongs.url = "/hype?feed=popular&time=3days&page=#{encodeURIComponent(page)}"
      @hypeSongs.fetch()

    hypePopularWeek: (page = 1) ->
      this.showSpinner()
      @hypeSongs.feed = 'Popular - Last Week'
      @hypeSongs.url = "/hype?feed=popular&time=week&page=#{encodeURIComponent(page)}"
      @hypeSongs.fetch()

    hypeUser: (user, page = 1) ->
      this.showSpinner()
      @hypeSongs.feed = "#{user}'s Songs"
      @hypeSongs.url = "/hype?username=#{encodeURIComponent(user)}&page=#{encodeURIComponent(page)}"
      @hypeSongs.fetch()


  window.workspace = new Warble.WorkspaceController
  Backbone.history.start pushState: true

  # Route all <a data-relative="true"> clicks automatically in-app.
  $('a[data-relative]').live 'click', (event) ->
    event.preventDefault()
    window.workspace.navigate($(event.currentTarget).attr('href'), true)

  socket = new io.Socket null,
    port: 8765
    rememberTransport: false
  socket.connect()
  socket.on 'message', (raw_data) ->
    data = JSON.parse(raw_data)
    switch data.event
      when 'refresh'
        window.workspace.queue.reset data.songs
      when 'skip'
        window.workspace.skip data.jukebox
      when 'volume'
        # TODO don't change the value if this is the window that set it
        # also, move this into a view or something
        $('#volume').slider('value', data.jukebox.volume)
      when 'reload'
        window.location.reload true

  $.mapKey 'enter', ->
    # TODO: pull up drawer and set focus to search
    console.log 'Enter key pressed'
