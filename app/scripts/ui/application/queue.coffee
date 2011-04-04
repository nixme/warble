class QueueView extends Backbone.View
  initialize: ->
    _.bindAll this, 'addSong', 'addAll', 'removeSong'
    @el = $('ul#songs')
    @collection.bind 'refresh', @addAll
    @collection.bind 'add', @addSong
    @collection.bind 'remove', @removeSong

  addSong: (song) ->
    view = new SongView { model: song }
    $(@el).append view.render().el

  addAll: ->
    @collection.each @addSong

  removeSong: (song) ->
    song.view.remove()
