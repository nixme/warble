Warble.JukeboxeRoute = Ember.Route.extend
  model: (params) ->
    Warble.Jukebox.find(params.jukebox_id)

