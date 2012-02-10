#= require jquery
#= require jquery-ui
#= require rails/csrf
#= require underscore
#= require backbone

#= require_self

#= require models/jukebox
#= require_tree ./ui/player

window.Warble = {}  # namespacing object for our classes

jQuery(document).ready ($) ->
  window.jukebox = jukebox = new Warble.Jukebox
  window.pandoraPlayer = new Warble.PandoraPlayerView model: jukebox
  window.youtubePlayer = new Warble.YoutubePlayerView model: jukebox

  jukebox.fetch()   # load current song to play

  socket = io.connect("http://#{window.base_url}:8765")
  socket.on 'message', (raw_data) ->
    data = JSON.parse(raw_data)
    jukebox.set data.jukebox

    switch data.event
      when 'reload'
        window.location.reload true
