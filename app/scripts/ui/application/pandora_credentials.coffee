class PandoraCredentialsView extends Backbone.View
  events:
    'click button'   : 'save'
    'submit form'    : 'save'

  initialize: ->
    _.bindAll this, 'render', 'save'
    @el = $('#add')

  template: -> window.templates['pandora_credentials']

  render: ->
    $(@el).html this.template()
    this.delegateEvents()   # TODO: all pre-initted views can't share #add is the issue here
    this

  save: (event) ->
    $.post '/app/pandora/credentials', this.$('#pandora_credentials').serialize(), =>
      window.workspace.pandoraStations()
    event.preventDefault()
    false
