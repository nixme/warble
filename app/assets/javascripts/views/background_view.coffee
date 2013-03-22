COVER_PHOTO_KEY = 'url'
Warble.BackgroundView = Ember.View.extend
  classNames: ['background-cover']
  classNameBindings: ['isStretched', 'isDarkened']
  attributeBindings: ['style']

  isDarkened: no
  isStretched: yes

  style: (->
    if @get(COVER_PHOTO_KEY)
      "background-image: url('#{@get(COVER_PHOTO_KEY)}')"
    else
      "background-image: none;"
  ).property(COVER_PHOTO_KEY)

