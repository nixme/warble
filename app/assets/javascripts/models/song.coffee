{attr, hasMany} = DS

Warble.Song = DS.Model.extend
  title: attr 'string'
  artist: attr 'string'
  coverUrl: attr 'string'
  url: attr 'string'
  source: attr 'string'
  plays: hasMany 'Warble.Play'
  voters: hasMany 'Warble.User'

  backgroundStyle: (->
    "background-image: url('#{@get('coverUrl')}')"
  ).property('coverUrl')
