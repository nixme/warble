class Warble.Vote extends Backbone.Model
  url: ->
    "/songs/#{@get('song_id')}/votes"

class Warble.VoteList extends Backbone.Collection
  model: Warble.Vote