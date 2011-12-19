class Warble.PaneView extends Backbone.View
  className: 'pane'

  # Default render implementation: Just renders the template to the element
  render: ->
    $(@el).html @template()
    this
