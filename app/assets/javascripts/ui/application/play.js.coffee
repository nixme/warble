#= require templates/play

class Warble.PlayView extends Backbone.View
  tagName:  'li'
  template: window.JST['templates/play']

  initialize: ->
    @model.bind 'change', @render, this
    @model.view = this

  render: ->
    $(@el).html @template @model.toJSON()
    @$('.submitter img[title]').tooltip
      effect:   'fade'
      position: 'bottom right'
      offset:   [5, -26]
    this

  remove: ->
    $(@el).remove()
