{attr, Model} = DS

Warble.User = Model.extend
  firstName: attr('string')
  lastName: attr('string')
  fullName: (->
      @get('firstName') + " " + @get('lastName')
    ).property('firstName', 'lastName')
  photoUrl: attr('string')

