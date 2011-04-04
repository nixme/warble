class Jukebox extends Backbone.Model
  url: '/jukebox'

  current_song: ->
    this.get('current')
