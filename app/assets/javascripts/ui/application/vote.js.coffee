#= require templates/vote

class Warble.VoteView extends Backbone.View
  template: window.JST['templates/vote']

  events:
    'click #vote' : 'handleVote'

  initialize: (opts) ->
    @el = $('.vote')
    @delegateEvents()

  render: ->
    $(@el).html this.template @model.toJSON()
    @

  handleVote: (e) ->
    votes = new Warble.VoteList @model.current_song().votes
    votes.create { song_id: @model.current_song().id },
      success: (model, resp) =>
        @trigger 'voteRecorded'

