# Node.js server to proxy redis pubsub messages to browser clients via socket.io
#  - redis pubsub only used to communicate from sinatra to this server
#  - socket.io tracks connected clients per node server
#  - right now only handles one global jukebox
#
# TODO: proper multiple jukebox support
#

redis = require('redis')
io    = require('socket.io').listen(8765)

# Production socket.io settings. Use NODE_ENV=production envvar
io.configure 'production', ->
  io.enable 'browser client minification'   # Send minified client JS
  io.enable 'browser client gzip'           # GZip the JS file
  io.enable 'browser client etag'           # ETag caching logic based on version number
  io.set 'log level', 1                     # Reduce logging

# Subscribe to redis pubsub channel and rebroadcast to socket.io clients
sub_client = redis.createClient()
sub_client.subscribe 'Jukebox:player'
sub_client.on 'message', (channel, message) ->
  io.sockets.send message

console.log "You're tuned to KWBL, Warble Live…"
