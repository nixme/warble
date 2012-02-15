#= require templates/current_play

class Warble.CurrentPlayView extends Backbone.View
  el: '#playing'

  initialize: ->
    _.bindAll this, 'refresh'

    @model.bind 'change', @render, this

    @voteView = new Warble.VoteView model: @model
    @voteView.bind 'voteRecorded', @refresh

  template: window.JST['templates/current_play']

  render: ->
    @$el.html this.template @model.toJSON()

    # user name tooltips on profile images
    @$('.submitter img[title]').tooltip  # TODO: dry up with PlayView
      effect:   'fade'
      position: 'bottom right'
      offset:   [5, -34]

    # update browser title with artist and song
    song = @model.current_play.get('song')
    if song
      document.title = "#{song.artist}: #{song.title} \u2022 Warble"
    else
      document.title = 'Warble'

    this

  refresh: ->
    @model.fetch success: => @render()
