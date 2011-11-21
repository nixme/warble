#= require templates/pandora_stations

class Warble.PandoraStationsView extends Backbone.View
  template: -> window.JST['templates/pandora_stations']

  events:
    'click #pandora_logout': 'logout'

  initialize: ->
    _.bindAll this, 'render', 'logout'
    @el = $('#add')

  render: ->
    $(@el).html @template()
      stations: @collection.toJSON()
    this.delegateEvents()  # TODO: fix

  logout: ->
    $.post '/pandora/credentials', _method: 'delete', ->
      window.workspace.navigate '/', true
