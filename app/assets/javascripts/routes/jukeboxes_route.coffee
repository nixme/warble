Warble.JukeboxesRoute = Ember.Route.extend
  model: ->
    Warble.Jukebox.find()

Warble.JukeboxeRoute = Ember.Route.extend
  model: (params) ->
    Warble.Jukebox.find(params.jukebox_id)

