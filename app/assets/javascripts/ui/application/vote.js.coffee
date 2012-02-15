#= require templates/vote

class Warble.VoteView extends Backbone.View
  el: '.vote'
  template: window.JST['templates/vote']

  events:
    'click #vote' : 'handleVote'

  initialize: (opts) ->
    @model.bind 'change', @render, this

  render: ->
    @$el.html @template @model.toJSON()
    this

  handleVote: (e) ->
    votes = new Warble.VoteList @model.current_play.get('song').votes
    votes.create { song_id: @model.current_play.get('song').id },
      success: (model, resp) =>
        @trigger 'voteRecorded'
