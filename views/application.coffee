# TODO: move all these templates to their own views

jQuery(document).ready ($) ->

  class Jukebox extends Backbone.Model
    url: '/app/jukebox'

  class PandoraStation extends Backbone.Model
    initialize: ->
      @songs = new PandoraSongList
      @songs.url = "/app/pandora/stations/#{@id}/songs"
      @songs.station = this

  class PandoraStationList extends Backbone.Collection
    model: PandoraStation
    url: '/app/pandora/stations'

  class PandoraSong extends Backbone.Model

  class PandoraSongList extends Backbone.Collection
    model: PandoraSong


  class Song extends Backbone.Model

  class SongList extends Backbone.Collection
    model: Song
    url: '/app/queue'


  class SongView extends Backbone.View
    tagName:  'li'
    template: Handlebars.compile '''
      <div class="submitter">{{user/first_name}} {{user/last_name}}</div>
      <img class="cover" src="{{cover_url}}" />
      <div class="name">
        <span class="artist">{{artist}}</span>:
        <span class="title">{{title}}</span>
      </div>
    '''

    initialize: ->
      _.bindAll this, 'render', 'remove'
      @model.bind 'change', @render
      @model.view = this

    render: ->
      $(@el).html @template(@model.toJSON())
      this

    remove: ->
      $(@el).remove()

  class QueueView extends Backbone.View
    el: $('ul#songs')

    initialize: ->
      _.bindAll this, 'addSong', 'addAll', 'removeSong'
      @collection.bind 'refresh', @addAll
      @collection.bind 'add', @addSong
      @collection.bind 'remove', @removeSong

    addSong: (song) ->
      view = new SongView { model: song }
      $(@el).append view.render().el

    addAll: ->
      @collection.each @addSong

    removeSong: (song) ->
      song.view.remove()

  class CurrentSongView extends Backbone.View
    el: $('#playing')

    initialize: ->
      _.bindAll this, 'render'
      @model.bind 'change', @render

    template: Handlebars.compile '''
      {{#current}}
        <img id="cover" src="{{cover_url}}" />
        <div id="artist">{{artist}}</div>
        <div id="title">{{title}}</div>
      {{^}}
        <div id="artist">No songs in queue</div>
      {{/current}}
    '''

    render: ->
      $(@el).html @template(@model.toJSON())
      this

  class ServiceChooserView extends Backbone.View
    el: $('#add')

    initialize: ->
      _.bindAll this, 'render'

    template: Handlebars.compile '''
      <h2>Sources</h2>
      <p>
        <a href="#!/pandora/stations">
          <img src="/images/pandora.png" />
        </a>
      </p>
    '''

    render: ->
      $(@el).html @template
      this

  class PandoraCredentialsView extends Backbone.View
    el: $('#add')

    events:
      'click button'   : 'save'
      'submit form'    : 'save'

    initialize: ->
      _.bindAll this, 'render', 'save'

    template: Handlebars.compile '''
      <div class="breadcrumbs">
        <a href="#!/">Sources</a>
        &raquo;
        <span class="current">Pandora</span>
      </div>
      <h2>Pandora Credentials</h2>
      <p>Enter your pandora username and password so we can grab your stations.</p>
      <form id="pandora_credentials" action="/app/pandora/credentials" method="post">
        <input type="text" name="pandora_username" placeholder="Email" />
        <input type="password" name="pandora_password" placeholder="Password" />
        <button>Save</button>
      </form>
    '''

    render: ->
      $(@el).html @template
      this.delegateEvents()   # TODO: all pre-initted views can't share #add is the issue here
      this

    save: (event) ->
      $.post '/app/pandora/credentials', this.$('#pandora_credentials').serialize(), =>
        window.workspace.pandoraStations()
      event.preventDefault()
      false

  class PandoraStationsView extends Backbone.View
    el: $('#add')

    template: Handlebars.compile '''
      <div class="breadcrumbs">
        <a href="#!/">Sources</a>
        &raquo;
        <span class="current">Pandora</span>
      </div>
      <h2>Your Pandora Stations</h2>
      <ul id="pandora_stations">
      {{#stations}}
        <li><a href="#!/pandora/stations/{{id}}">{{name}}</a></li>
      {{/stations}}
      </ul>
      {{^stations}}
      <p><em>You have no stations. Login to Pandora to add some.</em></p>
      {{/stations}}
      <a href="#" class="button" id="pandora_logout">Log out of Pandora</a>
    '''

    events:
      'click #pandora_logout': 'logout'

    initialize: ->
      _.bindAll this, 'render', 'logout'

    render: ->
      $(@el).html @template
        stations: @collection.toJSON()
      this.delegateEvents()  # TODO: fix

    logout: ->
      $.post '/app/pandora/credentials/clear', ->
        window.location.hash = "!/"


  class PandoraSongsView extends Backbone.View
    el: $('#add')
    template: Handlebars.compile '''
      <div class="breadcrumbs">
        <a href="#!/">Sources</a>
        &raquo;
        <a href="#!/pandora/stations">Pandora</a>
        &raquo;
        <span class="current">{{name}}</span>
      </div>
      <h2>Station: {{name}}</h2>
      <ul id="pandora_songs">
      {{#songs}}
        <li>
          <label>
            <input type="checkbox" data-id="{{id}}" />
            <span class="artist">{{artist}}</span>:
            <span class="title">{{title}}</span>
          </label>
        </li>
      {{/songs}}
      </ul>
      <a href="#" class="button" id="add_songs">Add Selected Songs</a>
      <a href="#" class="button" id="get_more" style="display:none">Get More Songs</a>
      <a href="#" class="button" id="select_all">Select All</a>
    '''

    events:
      'click #add_songs':  'addSongs'
      'click #get_more':   'getMore'
      'click #select_all': 'selectAll'

    initialize: ->
      _.bindAll this, 'render', 'addSongs', 'getMore', 'selectAll'

    render: ->
      $(@el).html @template
        name: @model.get 'name'
        songs: @model.songs.toJSON()

    addSongs: (event) ->
      song_ids = this.$('input:checkbox:checked').map(-> $(this).attr('data-id')).get()
      $.post '/app/queue',
        'song_id[]': song_ids
      @model.songs.fetch   # get more songs, TODO: this is whack, bind the collection properly
        success: => this.render()
        error:   -> window.location.hash = '!/pandora/stations'
      event.preventDefault()

    getMore: (event) ->
      event.preventDefault()

    selectAll: (event) ->
      this.$('input:checkbox').attr('checked', true)
      event.preventDefault()

  class WorkspaceController extends Backbone.Controller
    routes:
      ''                       : 'index'
      '!/'                     : 'home'
      '!/pandora/stations'     : 'pandoraStations'
      '!/pandora/stations/:id' : 'pandoraSongs'

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

      # load data
      @jukebox.fetch()
      @queue.fetch()
      @stationList.fetch()

      # player buttons. TODO: move to view class
      $('a#forward').click (event) ->
        $.post '/player/skip'
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
          setTimeout (-> notification.cancel()), 3000
        notification.show()

    index: ->
      window.location.hash = '!/'

    home: ->
      @serviceChooserView.render()

    pandoraStations: ->
      @stationList.fetch
        success: => @pandoraStationsView.render()
        error:   => @pandoraAuthView.render()

    pandoraSongs: (id) ->
      station = @stationList.get(id)
      if not station?   # can happen on page load directly to here
        @stationList.fetch()
        station = @stationList.get(id)

      if station?
        station.songs.fetch
          success: -> (new PandoraSongsView { model: station }).render()
          error:   -> window.location.hash = '!/pandora/stations'
      else  # redirect back to station list
        window.location.hash = '!/pandora/stations'


  window.workspace = new WorkspaceController
  Backbone.history.start()



  socket = new io.Socket 'localhost',
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

  $.mapKey 'enter', ->
    # TODO: pull up drawer and set focus to search
    console.log 'Enter key pressed'

