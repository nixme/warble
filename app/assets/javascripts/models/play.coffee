{belongsTo, attr} = DS

Warble.Play = DS.Model.extend
  user: belongsTo 'App.User'
  song: belongsTo 'App.Song'
  # jukebox: belongsTo 'App.Jukebox'
  skips: attr 'number'

