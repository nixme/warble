#= require ui/application/panes/pane
#= require templates/sources

class Warble.ServiceChooserView extends Backbone.View
  template: window.JST['templates/sources']
  # Default render implementation: Just renders the template to the element
  render: ->
    $(@el).html @template()
    this
