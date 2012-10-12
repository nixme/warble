#= require ui/application/panes/pane
#= require templates/sources

class Warble.ServiceChooserView extends Backbone.View
  template: window.JST['templates/sources']
  # Default render implementation: Just renders the template to the element
  render: ->
    $(@el).html @template()
    this

  autoSelectTab: ->
    target = if Backbone.history.fragment isnt "" then Backbone.history.fragment else "/"
    $("#sources .selected").toggleClass 'selected', no
    $("#sources [href='#{target}']").parent().toggleClass 'selected', yes

  # TODO: Create a collection of services.
  selectTab: (view) ->
