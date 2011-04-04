class SongView extends Backbone.View
  tagName:  'li'
  template: -> window.templates['song']

  initialize: ->
    _.bindAll this, 'render', 'remove'
    @model.bind 'change', @render
    @model.view = this

  render: ->
    $(@el).html @template()(@model.toJSON())
    this

  remove: ->
    $(@el).remove()
