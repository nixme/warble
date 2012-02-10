class Warble.ControlsView extends Backbone.View
  events:
    'click a#forward'  : 'skip'
    'click a#settings' : 'enableNotifications'

  initialize: ->
    _.bindAll @, 'skip'
    @el = $('#controls')
    @delegateEvents()

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
    $.post '/jukebox/skip'
    event.preventDefault()

  enableNotifications: ->
    if window.webkitNotifications?
      if window.webkitNotifications.checkPermission() == 0
        @notifications = true
      else
        window.webkitNotifications.requestPermission =>
          @notifications = (window.webkitNotifications.checkPermission() == 0)
    event.preventDefault()

  notify: (song) ->
    if @notifications
      notification = window.webkitNotifications.createNotification(song.cover_url, song.artist, song.title)
      notification.ondisplay = ->
        setTimeout (-> notification.cancel()), 5000
      notification.show()

