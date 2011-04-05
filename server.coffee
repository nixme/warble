# Node.js server to proxy redis pubsub messages to browser clients via socket.io
#  - redis pubsub only used to communicate from sinatra to this server
#  - socket.io tracks connected clients per node server
#  - right now only handles one global jukebox
#
# TODO: proper multiple jukebox support
#

http  = require('http')
io    = require('socket.io')
redis = require('redis')

# http server
server = http.createServer (req, res) ->
  res.writeHead 200, { 'Content-Type': 'text/html' }
  res.end 'Nothing to see here...'
server.listen 8765

# attach socket.io server
socket = io.listen server

# subscribe to redis channel and rebroadcast to socket.io clients
sub_client = redis.createClient()
sub_client.subscribe 'Jukebox:player'
sub_client.on 'message', (channel, message) ->
  socket.broadcast message
