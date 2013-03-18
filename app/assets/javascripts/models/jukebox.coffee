DS.RESTAdapter.configure "plurals", jukebox: "jukeboxes"
#DS.RESTAdapter.map 'Warble.Jukebox',
#  queue: {embedded: 'load'}
DS.RESTAdapter.configure 'Warble.Jukebox',
    sideloadAs: 'jukeboxes'

{hasMany, attr, Model} = DS

Warble.Jukebox = Model.extend
  name: attr 'string'
  plays: hasMany 'Warble.Play'
