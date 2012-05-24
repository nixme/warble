# Player for any audio file source. Only audio output, no UI elements.
#
# Listens to Jukebox change events to load and play new songs. Uses the Web
# Audio API to generate and control output.
#
# Exposes the following properties:
#   playing     - Is something being played?
#   currentTime - Seconds since the start of the song.
#   analyzer    - RealtimeAnalyserNode for real-time frequency analysis.
#
# Emits the following events:
#   start
#   stop
#
class Warble.AudioPlayer
  _.extend(@::, Backbone.Events)

  constructor: (@jukebox) ->
    @jukebox.current_play.on 'change:id', @songChanged, this
    @jukebox.on 'change:volume', @volumeChanged, this
    @resetState()

    # Setup Web Audio API context and nodes
    @audioContext =
      if window.AudioContext
        new AudioContext
      else if window.webkitAudioContext
        new webkitAudioContext
      else
        throw new Error('Web Audio API unavailable.')
    @gainNode = @audioContext.createGainNode()
    @gainNode.connect @audioContext.destination
    @gainNode.gain.value = 0.8

    @analyser = @audioContext.createAnalyser()
    @analyser.fftSize = 2048
    @analyser.smoothingTimeConstant = 0.75
    @analyser.connect @gainNode

    setInterval (=> @sourceNodeStateCheck()), 250


  # Play a new song when the current play changes, except when Youtube
  songChanged: ->
    if @jukebox.current_play.get('song')?.source == 'youtube'
      @stop
    else
      @loadAndPlay @jukebox.current_play.get('song').url

  # Updates the GainNode based on the Jukebox's volume.
  volumeChanged: ->
    # TODO: Handle pandora gain information
    @gainNode.gain.value = @jukebox.get('volume') / 100


  # Reset properties that track current audio state.
  resetState: ->
    @playing = false      # Is a song playing or not?
    @startTime = -1       # AudioContext.currentTime at start of play
    @currentTime = 0      # Seconds since start of play


  # Loads and play an audio URL.
  loadAndPlay: (url) ->
    # TODO: Switch to MediaElementAudioSourceNode for streaming support
    xhr = new XMLHttpRequest          # jQuery doesn't support the arraybuffer
    xhr.open('GET', url, true)        #   responseType, so manually constructing
    xhr.responseType = 'arraybuffer'  #   an XHR object.
    xhr.onload = (event) =>     # TODO: check decodeAudioData is available
      @audioContext.decodeAudioData xhr.response, (buffer) =>
        @load buffer
        @play()
      , (errorEvent) =>
        console.log 'Error decoding audio file', url, errorEvent
        @jukebox.skip()
    xhr.send()


  # Load audio data into a new AudioBufferSourceNode
  load: (buffer) ->
    @stop()
    @source.disconnect @analyser if @source   # Cleanup existing source
    @source = @audioContext.createBufferSource()
    @source.connect @analyser
    @source.buffer = buffer
    @source.loop = false
    @resetState()


  # Play the loaded song
  play: ->
    # TODO: check buffer has a loaded song
    @playing = true
    @startTime = @audioContext.currentTime + @currentTime
    @source.noteGrainOn 0, @currentTime, @source.buffer.duration
    @trigger 'start'


  # Pauses playback if a song is currently playing
  stop: ->
    if @source && @playing
      @source.noteOff 0
      @resetState()   # TODO: save off currentTime
      @trigger 'stop'


  # Poller to determine playback state since AudioBufferSourceNode's don't have
  # events.
  sourceNodeStateCheck: ->
    return unless @source
    state = @source.playbackState

    # Since we're syncing various local states to the Web Audio API state, check
    # our assumptions.
    if !@playing && @source.PLAYING_STATE == state
      throw new Error('Audio tracking error')

    # Update state properties. Notify server if a song finished playing.
    if @playing
      if @source.FINISHED_STATE == state        # Finished playing
        @resetState()
        @trigger 'stop'
        @jukebox.skip()
      else if @source.PLAYING_STATE == state    # Still playing
        @currentTime = @audioContext.currentTime - @startTime
