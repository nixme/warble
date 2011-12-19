#= require ui/application/panes/pane
#= require templates/pandora_stations

class Warble.PandoraStationsView extends Warble.PaneView
  template: window.JST['templates/pandora_stations']

  events:
    'click #pandora_logout': 'logout'

  render: ->
    $(@el).html @template
      stations: @collection.toJSON()
    this

  logout: ->
    $.post '/pandora/credentials', _method: 'delete', ->
      window.workspace.navigate '/', true
