{attr, hasMany} = DS

Warble.Song = DS.Model.extend
  title: attr 'string'
  plays: hasMany 'App.Play'

