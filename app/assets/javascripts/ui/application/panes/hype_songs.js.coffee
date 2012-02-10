#= require ui/application/panes/pane
#= require templates/hype_songs

# TODO: the lack of abstraction is getting annoying. DRY up
class Warble.HypeSongsView extends Warble.PaneView
  template: window.JST['templates/hype_songs']

  events:
    'click a.result' : 'queueSong'

  initialize: ->
    @collection.bind 'all', @render, this

  render: ->
    $(@el).html @template
      feed:  @collection.feed
      songs: @collection.toJSON()
    window.workspace.hideSpinner()
    this

  queueSong: (event) ->
    window.workspace.showSpinner()

    song_id = $(event.currentTarget).attr('data-id')
    $.post '/jukebox/playlist',
      'song_id[]': [song_id]

    window.workspace.hideSpinner()
    event.preventDefault()
