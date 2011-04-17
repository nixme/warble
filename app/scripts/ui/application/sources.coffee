class ServiceChooserView extends Backbone.View
  initialize: ->
    _.bindAll this, 'render'
    @el = $('#add .content')

  template: -> window.templates['sources']

  render: ->
    $(@el).html @template()
    this
