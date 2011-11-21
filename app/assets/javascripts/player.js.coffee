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
  window.jukebox = new Warble.Jukebox
  window.pandoraPlayer = new Warble.PandoraPlayerView model: window.jukebox
  window.youtubePlayer = new Warble.YoutubePlayerView model: window.jukebox

  window.jukebox.fetch()   # load current song to play

  socket = new io.Socket null,
    port: 8765
    rememberTransport: false
  socket.connect()
  socket.on 'message', (raw_data) ->
    data = JSON.parse(raw_data)
    switch data.event
      when 'skip'
        window.jukebox.set data.jukebox
      when 'volume'
        window.jukebox.set data.jukebox
      when 'reload'
        window.location.reload true
