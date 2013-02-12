#= require ui/application/panes/pane
#= require templates/party/party_songs

class Warble.PartySongsView extends Warble.PaneView
  template: window.JST['templates/party/party_songs']

  events:
    'click li' : 'queueSong'

  initialize: ->
    @collection.bind 'all', @render, this

  render: ->
    @$el.html @template
      noSongs: @collection.size() == 0
      songs: @collection.toJSON()
      field: @collection.field
      char: @collection.char.toUpperCase()
    @

  queueSong: (event) ->
    song_id = $(event.currentTarget).attr('data-id')
    $.post '/jukebox/playlist',
      'song_id[]': [song_id]

    event.preventDefault()
    window.workspace.navigate '/party/app', true
