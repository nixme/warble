jQuery(document).ready ($) ->

  class Jukebox extends Backbone.Model
    url: '/app/current'


  class PlayerView extends Backbone.View
    el: $('#embed')

    template: Handlebars.compile '''
      <audio src="{{url}}" />
    '''

    initialize: ->
      _.bindAll this, 'render'
      jukebox.bind 'change', @render
      jukebox.fetch()

    render: ->
      $(@el).html @template(jukebox.toJSON())


  window.jukebox = new Jukebox
  window.player = new PlayerView

  socket = new io.Socket 'localhost',
    port: 8080
    rememberTransport: false
  socket.connect()
  socket.on 'message', (data) ->
    window.jukebox.refresh data