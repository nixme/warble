#= require ui/application/panes/pane
#= require templates/rdio

class Warble.RdioView extends Warble.PaneView
  template: window.JST['templates/rdio']

  events:
    'click a.library_search' : 'search'
    'click a.result'         : 'queueTrack'

  initialize: ->
    @collection = new Warble.RdioSongList
    @collection.bind 'all', @render, this

  render: ->
    @$el.html @template
      query:   @collection.query
      results: @collection.toJSON()
    this

  activate: ->
    @$('#search_query').focus()

  search: (event) ->
    @collection.query = @$('#search_query').val()

    window.workspace.showSpinner()
    @collection.fetch
      success: -> window.workspace.hideSpinner()
      error: ->
        window.workspace.navigate '/', true
        window.workspace.hideSpinner()

    event.preventDefault()

  queueTrack: (event) ->
    window.workspace.showSpinner()

    song_id = $(event.currentTarget).attr('data-id')
    $.post '/jukebox/playlist',
      'song_id[]': [song_id]

    window.workspace.hideSpinner()
    event.preventDefault()