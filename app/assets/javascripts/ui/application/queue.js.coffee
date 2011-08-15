class Warble.QueueView extends Backbone.View
  initialize: ->
    _.bindAll this, 'addSong', 'addAll', 'removeSong'
    @el = $('ul#songs')
    @collection.bind 'reset', @addAll
    @collection.bind 'add', @addSong
    @collection.bind 'remove', @removeSong

  addSong: (song) ->
    view = new SongView { model: song }
    $(@el).append view.render().el

  addAll: ->
    $(@el).html ''
    @collection.each @addSong

  removeSong: (song) ->
    song.view.remove()
