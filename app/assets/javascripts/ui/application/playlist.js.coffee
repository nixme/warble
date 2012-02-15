class Warble.PlaylistView extends Backbone.View
  el: 'ul#songs'

  initialize: ->
    @collection.bind 'reset', @addAll, this
    @collection.bind 'add', @addPlay, this
    @collection.bind 'remove', @removePlay, this

  addPlay: (play) ->
    view = new Warble.PlayView { model: play }
    @$el.append view.render().el

  addAll: ->
    @$el.html ''
    @collection.each @addPlay, this

  removePlay: (play) ->
    play.view.remove()
