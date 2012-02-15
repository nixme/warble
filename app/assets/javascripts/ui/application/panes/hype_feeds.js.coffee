#= require ui/application/panes/pane
#= require templates/hype_feeds

class Warble.HypeFeedsView extends Warble.PaneView
  template: window.JST['templates/hype_feeds']

  events:
    'click #username_search' : 'usernameSearch'
    'keypress input'         : 'handleEnter'

  usernameSearch: (event) ->
    username = @$('#username_query').val()
    window.workspace.navigate '/hype/#{username}/1', true
    event.preventDefault()

  handleEnter: (event) ->
