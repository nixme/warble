#= require ui/application/panes/pane
#= require templates/pandora_credentials

class Warble.PandoraCredentialsView extends Warble.PaneView
  template: window.JST['templates/pandora_credentials']

  events:
    'click button'   : 'save'
    'submit form'    : 'save'

  save: (event) ->
    # TODO: generalize the method shim
    $.post '/pandora/credentials', this.$('#pandora_credentials').serialize() + '&_method=PUT', =>
      window.workspace.pandoraStations()
    , 'json'
    event.preventDefault()
    false
