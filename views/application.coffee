# TODO: move all these templates to their own views

jQuery(document).ready ($) ->

  class Jukebox extends Backbone.Model
    url: '/app/current'

  class PandoraStation extends Backbone.Model
    initialize: ->
      @songs = new PandoraSongList
      @songs.url = "/app/pandora/stations/#{@id}/songs"

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
      <div class="submitter">{{user/name}}</div>
      <img class="cover" src="{{cover_url}}" />
      <div class="name">
        <span class="artist">{{artist}}</span>:
        <span class="title">{{title}}</span>
      </div>
    '''

    initialize: ->
      _.bindAll this, 'render'
      @model.bind 'change', @render

    render: ->
      $(@el).html @template(@model.toJSON())
      this

  class QueueView extends Backbone.View
    el: $('#queue ul')

    initialize: ->
      _.bindAll this, 'addSong', 'addAll'
      @collection.bind 'refresh', @addAll
      @collection.fetch()

    addSong: (song) ->
      view = new SongView { model: song }
      $(@el).append view.render().el

    addAll: ->
      @collection.each @addSong

  class CurrentSongView extends Backbone.View
    el: $('#playing')

    initialize: ->
      _.bindAll this, 'render'
      @model.bind 'change', @render
      @model.fetch()

    template: Handlebars.compile '''
      {{#current}}
        <img id="cover" src="{{cover_url}}" />
        <div id="artist">{{artist}}</div>
        <div id="title">{{title}}</div>
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
      <h2>Services</h2>
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
      'click button' : 'save'

    initialize: ->
      _.bindAll this, 'render', 'save'

    template: Handlebars.compile '''
      <h2>Pandora Credentials</h2>
      <p>Enter your pandora username and password so we can grab your stations.</p>
      <form id="pandora_credentials">
        <input type="text" name="pandora_username" placeholder="Email" />
        <input type="password" name="pandora_password" placeholder="Password" />
        <button>Save</button>
      </form>
      <a href="#!/" class="back">Back to Services</a>
    '''

    render: ->
      $(@el).html @template
      this

    save: ->
      $.post '/app/pandora/credentials', this.$('#pandora_credentials').serialize(), =>
        window.location.hash = '!/pandora/stations'
      false

  class PandoraStationsView extends Backbone.View
    el: $('#add')

    template: Handlebars.compile '''
      <h2>Your Pandora Stations</h2>
      <ul id="pandora_stations">
      {{#stations}}
        <li class="station"><a href="#!/pandora/stations/{{id}}">{{name}}</a></li>
      {{^}}
        <li><em>You have no stations. Login to Pandora to add some.</em></li>
      {{/stations}}
      </ul>
      <a href="#!/" class="button">Back to Services</a>
      <a href="#!/" class="button" id="pandora_logout">Log out of Pandora</a>
    '''

    initialize: ->
      _.bindAll this, 'render'
      @collection.bind 'refresh', @render

    render: ->
      $(@el).html @template
        stations: @collection.toJSON()


  class WorkspaceController extends Backbone.Controller
    routes:
      ''                       : 'index'
      '!/'                     : 'home'
      '!/pandora/stations'     : 'pandoraStations'
      '!/pandora/stations/:id' : 'pandoraSongs'

    initialize: ->
      @jukebox = new Jukebox
      @queue = new SongList
      @stationList = new PandoraStationList
      @currentSongView ||= new CurrentSongView { model: @jukebox }
      @queueView ||= new QueueView { collection: @queue }
      @serviceChooserView ||= new ServiceChooserView
      @pandoraAuthView ||= new PandoraCredentialsView
      @pandoraStationsView ||= new PandoraStationsView { collection: @stationList }

    index: ->
      window.location.hash = '!/'

    home: ->
      @serviceChooserView.render()

    pandoraStations: ->
      @stationList.fetch
        success: => @pandoraStationsView.render()
        error:   => @pandoraAuthView.render()

    pandoraSongs: (id) ->
      @pandoraSongView = new PandoraSongView { model: @queue.get(id) }
      @pandoraSongView.render()


  window.workspace = new WorkspaceController
  Backbone.history.start()



  socket = new io.Socket 'localhost',
    port: 8080
    rememberTransport: false
  socket.connect()
  socket.on 'message', (data) ->
    window.jukebox.refresh data

  $.mapKey 'enter', ->
    # TODO: pull up drawer and set focus to search
    console.log 'Enter key pressed'

