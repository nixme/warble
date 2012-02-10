class Warble.Jukebox extends Backbone.Model
  url: '/jukebox'

  current_play: ->
    this.get('current_play')
