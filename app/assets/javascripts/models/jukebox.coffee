DS.RESTAdapter.configure "plurals", jukebox: "jukeboxes"
DS.RESTAdapter.map 'Warble.Jukebox',
  queue: {embedded: 'load'}

{hasMany, attr, Model} = DS

Warble.Jukebox = Model.extend
  name: attr 'string'
  queue: hasMany 'Warble.Play'
