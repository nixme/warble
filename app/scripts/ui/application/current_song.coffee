class CurrentSongView extends Backbone.View
  initialize: ->
    _.bindAll this, 'render'
    @el = $('#playing')
    @model.bind 'change', @render

  template: -> window.templates['current_song']

  render: ->
    $(@el).html this.template()(@model.toJSON())
    this.$('.submitter img[title]').tooltip  # TODO: dry up with SongView
      effect:   'fade'
      position: 'bottom right'
      offset:   [5, -34]
    this
