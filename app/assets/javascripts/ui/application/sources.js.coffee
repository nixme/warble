#= require templates/sources

class Warble.ServiceChooserView extends Backbone.View
  initialize: ->
    _.bindAll this, 'render'
    @el = $('#add')

  template: -> window.JST['templates/sources']

  render: ->
    $(@el).html @template()
    this
