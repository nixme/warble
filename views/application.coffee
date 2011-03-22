jQuery(document).ready ($) ->

  class Jukebox extends Backbone.Model
    url: '/app/current'

  window.jukebox = new Jukebox


  class Song extends Backbone.Model


  class SongList extends Backbone.Collection
    model: Song


  window.queue = new SongList

  class SongView extends Backbone.View
    tagName:  'li'
    template: Handlebars.compile '''
      <li>
        <div class="submitter">{{user/name}}</div>
        <img class="cover" src="{{photo_url}}" />
        <div class="title">
          <span class="artist">{{artist}}</span>
          -
          <span class="title">{{title}}</span>
        </div>
      </li>
    '''

    initialize: ->
      _.bindAll this, 'render'
      @model.bind 'change', @render

    render: ->
      $(@el).html @template(@model.toJSON())
      this


  class AppView extends Backbone.View
    el: $('body')

    initialize: ->
      _.bindAll this, 'render'
      jukebox.bind 'change', @render
      jukebox.fetch()

    currentSongTemplate: Handlebars.compile '''
      {{#current}}
        <img id="cover" src="{{cover_url}}" />
        <div id="artist">{{artist}}</div>
        <div id="title">{{title}}</div>
      {{/current}}
    '''

    render: ->
      this.$('#playing').html @currentSongTemplate(jukebox.toJSON())
      this

  window.app = new AppView


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

