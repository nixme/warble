class Warble.HeaderView extends Backbone.View
  el: 'body > header'

  events:
    'click a#forward'  : 'skip'
    'click a#settings' : 'enableNotifications'

  initialize: ->
    @model.current_play.bind 'change:id', @notify, this

    @notifications = (window.webkitNotifications?.checkPermission() == 0)

    # Volume controls
    @$('#volume').slider
      animate: true
      value: $('#volume').data 'volume'
      stop: (e, ui) ->
        $.ajax '/jukebox/volume'
          type: 'put'
          data:
            value: ui.value

  skip: (event) ->
    @model.skip()
    event.preventDefault()

  enableNotifications: ->
    if window.webkitNotifications?
      if window.webkitNotifications.checkPermission() == 0
        @notifications = true
      else
        window.webkitNotifications.requestPermission =>
          @notifications = (window.webkitNotifications.checkPermission() == 0)
    event.preventDefault()

  notify: ->
    if @notifications && @model.current_play
      song = @model.current_play.get('song')
      notification = window.webkitNotifications.createNotification(song.cover_url, song.artist, song.title)
      notification.ondisplay = ->
        setTimeout (=> @cancel()), 5000
      notification.onclick = -> @cancel()
      notification.show()
