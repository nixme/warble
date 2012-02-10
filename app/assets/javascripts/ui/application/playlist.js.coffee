class Warble.PlaylistView extends Backbone.View
  initialize: ->
    _.bindAll this, 'addPlay', 'addAll', 'removePlay'
    @el = $('ul#songs')
    @collection.bind 'reset', @addAll
    @collection.bind 'add', @addPlay
    @collection.bind 'remove', @removePlay

  addPlay: (play) ->
    view = new Warble.PlayView { model: play }
    $(@el).append view.render().el

  addAll: ->
    $(@el).html ''
    @collection.each @addPlay

  removePlay: (play) ->
    play.view.remove()
