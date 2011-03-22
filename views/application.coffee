jQuery(document).ready ($) ->

  class Jukebox extends Backbone.Model
    url: '/app/current'



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
        <span class="artist">{{artist}}</span>
        -
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
      queue.bind 'refresh', @addAll
      queue.fetch()

    addSong: (song) ->
      view = new SongView { model: song }
      $(@el).append view.render().el

    addAll: ->
      queue.each @addSong

  class CurrentSongView extends Backbone.View
    el: $('#playing')

    initialize: ->
      _.bindAll this, 'render'
      jukebox.bind 'change', @render
      jukebox.fetch()

    template: Handlebars.compile '''
      {{#current}}
        <img id="cover" src="{{cover_url}}" />
        <div id="artist">{{artist}}</div>
        <div id="title">{{title}}</div>
      {{/current}}
    '''

    render: ->
      $(@el).html @template(jukebox.toJSON())
      this

  window.jukebox = new Jukebox
  window.queue = new SongList
  window.currentSongView = new CurrentSongView
  window.queueView = new QueueView


  class PlayerView extends Backbone.View
    el: $('#embed')

    template: Handlebars.compile '''
      <audio src="{{url}}" />
    '''

    render: ->
      $(@el).html @template(jukebox.toJSON())

  socket = new io.Socket 'localhost', { port: 8080 }
  socket.connect()
  #socket.on 'message'
  # TODO: reconnection on failure?

  $.mapKey 'enter', ->
    # TODO: pull up drawer and set focus to search
    console.log 'Enter key pressed'

