#= require ui/application/panes/pane
#= require templates/pandora_songs

class Warble.PandoraSongsView extends Warble.PaneView
  template: window.JST['templates/pandora_songs']

  events:
    'click #add_songs':  'addSongs'
    'click #get_more':   'getMore'
    'click #select_all': 'selectAll'

  render: ->
    $(@el).html @template
      name: @model.get 'name'
      songs: @model.songs.toJSON()
    this

  addSongs: (event) ->
    window.workspace.showSpinner()
    song_ids = this.$('input:checkbox:checked').map(-> $(this).attr('data-id')).get()
    $.post '/jukebox/songs',
      'song_id[]': song_ids
    @model.songs.fetch   # get more songs, TODO: this is whack, bind the collection properly
      success: =>
        this.render()
        window.workspace.hideSpinner()
      error: ->
        window.workspace.navigate '/pandora/stations', true
    event.preventDefault()

  getMore: (event) ->
    event.preventDefault()

  selectAll: (event) ->
    @$('input:checkbox').attr('checked', true)
    event.preventDefault()
