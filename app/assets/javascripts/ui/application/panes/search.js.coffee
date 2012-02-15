#= require ui/application/panes/pane
#= require templates/search

# TODO: abstract some of this stuff out to a generic
#       search class that Youtube can share
class Warble.SearchView extends Warble.PaneView
  template: window.JST['templates/search']

  events:
    'click a.library_search' : 'search'
    'keypress input'         : 'handleEnter'
    'click a.result'         : 'queueVideo'

  initialize: ->
    @collection = new Warble.SearchList
    @collection.bind 'all', @render, this

  render: ->
    @$el.html @template
      query:   @collection.query
      results: @collection.toJSON()
    this

  activate: ->
    @$('#search_query').focus()

  handleEnter: (event) ->
    if event.which == 13
      this.search event

  search: (event) ->
    @collection.query = @$('#search_query').val()

    window.workspace.showSpinner()
    @collection.fetch
      success: -> window.workspace.hideSpinner()
      error: ->
        window.workspace.navigate '/', true
        window.workspace.hideSpinner()

    event.preventDefault()

  queueVideo: (event) ->
    window.workspace.showSpinner()

    song_id = $(event.currentTarget).attr('data-id')
    $.post '/jukebox/playlist',
      'song_id[]': [song_id]

    window.workspace.hideSpinner()
    event.preventDefault()
