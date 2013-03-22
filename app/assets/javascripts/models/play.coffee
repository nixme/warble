{belongsTo, attr} = DS

Warble.Play = DS.Model.extend
  song:     belongsTo 'Warble.Song'
  jukebox:  belongsTo 'Warble.Jukebox'
  skips:    attr 'number'
  user:     belongsTo 'Warble.User'
