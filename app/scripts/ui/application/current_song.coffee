class CurrentSongView extends Backbone.View
  initialize: ->
    _.bindAll this, 'render'
    @el = $('#playing')
    @model.bind 'change', @render

  template: -> window.templates['current_song']

  render: ->
    $(@el).html this.template()(@model.toJSON())
    this
