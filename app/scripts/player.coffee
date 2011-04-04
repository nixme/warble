jQuery(document).ready ($) ->
  window.jukebox = new Jukebox
  window.player = new PlayerView model: window.jukebox

  window.jukebox.fetch()   # load current song to play

  socket = new io.Socket null,
    port: 8080
    rememberTransport: false
  socket.connect()
  socket.on 'message', (raw_data) ->
    data = JSON.parse(raw_data)
    switch data.event
      when 'skip'
        window.jukebox.set data.jukebox
      when 'reload'
        window.location.reload true
