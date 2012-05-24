#= require templates/player_song

class Warble.SongPlayerView extends Backbone.View
  el: '#player'
  template: window.JST['templates/player_song']


  initialize: (options) ->
    @model.current_play.on 'change:id', @render, this


  render: ->
    @$el.html @template
      current: @model.current_play.get('song')
