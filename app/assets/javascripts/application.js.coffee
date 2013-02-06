#= require handlebars.1.0.0.beta.3
#= require jquery
#= require jquery-ui
#= require rails/csrf
#= require rails/method
#= require underscore
#= require backbone
#= require faye-browser
#= require jquery.mapkey
#= require tooltip
#= require_self

#= require_tree ./components
#= require_tree ./models
#= require_tree ./ui/application

window.Warble = {}  # namespacing object for our classes

jQuery(document).ready ($) ->
  class Warble.WorkspaceRouter extends Backbone.Router
    routes:
      'search'                    : 'search'
      'search/:query'             : 'search'
      'pandora/stations'          : 'pandoraStations'
      'pandora/stations/:id'      : 'pandoraSongs'
      'youtube'                   : 'youtube'
      'hype'                      : 'hypeChooser'
      'hype/latest/:page'         : 'hypeLatest'
      'hype/popular/3days/:page'  : 'hypePopular3Days'
      'hype/popular/week/:page'   : 'hypePopularWeek'
      'hype/:user/:page'          : 'hypeUser'
      'soundcloud'                : 'soundcloud'
      '*unmatched'                : 'home'

    initialize: ->
      # initialize models/collections
      @jukebox     = new Warble.Jukebox   # TODO: switch to a single song model instead of full jukebox state
      @playlist    = new Warble.Playlist
      @searchView  = new Warble.SearchView
      @stationList = new Warble.PandoraStationList
      @hypeSongs   = new Warble.HypeSongList

      # initialize views
      @headerView             = new Warble.HeaderView model: @jukebox
      @currentPlayView        = new Warble.CurrentPlayView model: @jukebox
      @playlistView           = new Warble.PlaylistView collection: @playlist
      @serviceChooserView     = new Warble.ServiceChooserView
      @pandoraAuthView        = new Warble.PandoraCredentialsView
      @pandoraStationsView    = new Warble.PandoraStationsView collection: @stationList
      @youtubeSearchView      = new Warble.YoutubeSearchView
      @hypeChooserView        = new Warble.HypeFeedsView
      @hypeSongsView          = new Warble.HypeSongsView collection: @hypeSongs
      @soundcloudSearchView   = new Warble.SoundcloudSearchView

      # load data
      @jukebox.fetch()
      @playlist.fetch()
      @stationList.fetch()

      @paneEl = $('#add')
      @currentPane = null

    skip: (jukebox) ->
      @jukebox.set jukebox                 # Update current song
      promoted_play = @playlist.at(0)
      if promoted_play?
        @playlist.remove(promoted_play)    # Remove top song in queue
      else
        @playlist.fetch()                  # Refetch in case of error

    # TODO: move to the proper single #app view
    showSpinner: -> $('#spinner').fadeIn()
    hideSpinner: -> $('#spinner').fadeOut()

    switchPane: (view) ->
      $(@currentView.el).remove() if @currentView
      @paneEl.append view.render().el
      view.delegateEvents()   # TODO: make this unnecessary
      view.activate?()
      @currentView = view

    home: ->
      @switchPane @serviceChooserView

    search: (query) ->
      #if query?
        # TODO: fill in
      @switchPane @searchView

    pandoraStations: ->
      this.showSpinner()
      @stationList.fetch
        success: =>
          @switchPane @pandoraStationsView
          this.hideSpinner()
        error: =>
          @switchPane @pandoraAuthView
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
            @switchPane (new Warble.PandoraSongsView { model: station })
            this.hideSpinner()
          error: =>
            window.workspace.navigate '/pandora/stations', true
      else  # redirect back to station list
        window.workspace.navigate '/pandora/stations', true

    youtube: ->
      @switchPane @youtubeSearchView

    hypeChooser: ->
      @switchPane @hypeChooserView


    # TODO: dry up these hype view flows

    hypeLatest: (page = 1) ->
      this.showSpinner()
      @hypeSongs.feed = 'Latest'
      @hypeSongs.url = "/hype?feed=latest&page=#{encodeURIComponent(page)}"
      @hypeSongs.fetch
        success: =>
          @switchPane @hypeSongsView

    hypePopular3Days: (page = 1) ->
      this.showSpinner()
      @hypeSongs.feed = 'Popular - Last 3 Days'
      @hypeSongs.url = "/hype?feed=popular&time=3days&page=#{encodeURIComponent(page)}"
      @hypeSongs.fetch
        success: =>
          @switchPane @hypeSongsView

    hypePopularWeek: (page = 1) ->
      this.showSpinner()
      @hypeSongs.feed = 'Popular - Last Week'
      @hypeSongs.url = "/hype?feed=popular&time=week&page=#{encodeURIComponent(page)}"
      @hypeSongs.fetch
        success: =>
          @switchPane @hypeSongsView

    hypeUser: (user, page = 1) ->
      this.showSpinner()
      @hypeSongs.feed = "#{user}'s Songs"
      @hypeSongs.url = "/hype?username=#{encodeURIComponent(user)}&page=#{encodeURIComponent(page)}"
      @hypeSongs.fetch
        success: =>
          @switchPane @hypeSongsView

    soundcloud: ->
      #SC.initialize client_id: "dae39b5eb16934e43c93209cb65051ee"
      @switchPane @soundcloudSearchView

  window.workspace = workspace = new Warble.WorkspaceRouter
  Backbone.history.start pushState: true

  # Route all <a data-relative="true"> clicks automatically in-app.
  $('a[data-relative]').live 'click', (event) ->
    event.preventDefault()
    workspace.navigate $(event.currentTarget).attr('href'), trigger: true

  Warble.push.initialize()
  Warble.push.bind 'jukebox:change', (data) ->
    workspace.jukebox.set data.jukebox
    workspace.playlist.reset data.jukebox.playlist

  # TODO don't change the value if this is the window that set it
  # also, move this into a view or something
  workspace.jukebox.bind 'change:volume', ->
    $('#volume').slider('value', workspace.jukebox.get('volume'))


  $.mapKey 'enter', ->
    # TODO: pull up drawer and set focus to search
    console.log 'Enter key pressed'
