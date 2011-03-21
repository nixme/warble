jQuery(document).ready ($) ->

  class Song extends Backbone.Model


  class SongList extends Backbone.Collection
    model: Song


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


  class CurrentSongView extends Backbone.View
    tagName: '#playing'

    template: Handlebars.compile '''
      <div id="playing">
        <img id="cover" src="{{cover_url}}" />
        <div id="artist">{{artist}}</div>
        <div id="title">{{title}}</div>
      </div>
    '''


  class AppView extends Backbone.View


  class PlayerView extends Backbone.View
    tagName: '#embed'

    template: Handlebars.compile '''
      <div id="embed">
        <audio src="{{url}}" />
      </div>
    '''


  socket = new io.Socket 'localhost:8080'
  socket.connect()
  #socket.on 'message'

  # TODO: reconnection on failure?

  $.mapKey 'enter', ->
    # TODO: pull up drawer and set focus to search
    console.log 'Enter key pressed'

