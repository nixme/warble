class CurrentSongView extends Backbone.View
  initialize: ->
    _.bindAll this, 'render'
    @el = $('#playing')
    @model.bind 'change', @render

  template: -> window.templates['current_song']

  render: ->
    $(@el).html this.template()(@model.toJSON())

    # user name tooltips on profile images
    this.$('.submitter img[title]').tooltip  # TODO: dry up with SongView
      effect:   'fade'
      position: 'bottom right'
      offset:   [5, -34]

    # update browser title with artist and song
    song = @model.current_song()
    if song
      document.title = "#{song.artist}: #{song.title} \u2022 Warble"
    else
      document.title = 'Warble'

    this
