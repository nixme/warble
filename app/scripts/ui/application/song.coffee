class SongView extends Backbone.View
  tagName:  'li'
  template: -> window.templates['song']

  initialize: ->
    _.bindAll this, 'render', 'remove'
    @model.bind 'change', @render
    @model.view = this

  render: ->
    $(@el).html @template()(@model.toJSON())
    this.$('.submitter img[title]').tooltip
      effect:   'fade'
      position: 'bottom right'
      offset:   [5, -26]
    this

  remove: ->
    $(@el).remove()
