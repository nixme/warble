#= require templates/vote

class Warble.VoteView extends Backbone.View
  template: window.JST['templates/vote']

  events:
    'click #vote' : 'handleVote'

  initialize: (opts) ->
    @el = $('.vote')

    @model.bind 'change', @render, this

    @delegateEvents()

  render: ->
    $(@el).html this.template @model.toJSON()
    @

  handleVote: (e) ->
    votes = new Warble.VoteList @model.current_play().song.votes
    votes.create { song_id: @model.current_play().song.id },
      success: (model, resp) =>
        @trigger 'voteRecorded'
