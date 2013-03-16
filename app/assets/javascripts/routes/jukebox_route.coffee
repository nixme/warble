Warble.JukeboxesRoute = Ember.Route.extend
  model: ->
    Warble.Jukebox.all()
