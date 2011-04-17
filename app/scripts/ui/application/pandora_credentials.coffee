class PandoraCredentialsView extends Backbone.View
  events:
    'click button'   : 'save'
    'submit form'    : 'save'

  initialize: ->
    _.bindAll this, 'render', 'save'
    @el = $('#add .content')

  template: -> window.templates['pandora_credentials']

  render: ->
    $(@el).html this.template()
    this.delegateEvents()   # TODO: all pre-initted views can't share #add is the issue here
    this

  save: (event) ->
    # TODO: generalize the method shim
    $.post '/pandora/credentials', this.$('#pandora_credentials').serialize() + '&_method=PUT', =>
      window.workspace.pandoraStations()
    event.preventDefault()
    false
