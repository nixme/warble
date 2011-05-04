# TODO: abstract some of this stuff out to a generic
#       search class that Youtube can share
class SearchView extends Backbone.View
  template: -> window.templates['search']

  events:
    'click #library_search' : 'search'
    'keypress input'        : 'handleEnter'
    'click a.result'        : 'queueVideo'

  initialize: ->
    _.bindAll this, 'render', 'search', 'handleEnter', 'queueVideo'
    @collection = new SearchList
    @collection.bind 'all', @render
    @el = $('#add .content')

  render: ->   
    el = $ @el  
    if @collection.query       
      re = new RegExp @collection.query, "gi"
      strong = "<strong>#{@collection.query}</strong>"
      el.html @template()
          query:   @collection.query
          results: @collection.toJSON()
    else
      el.html(
          (@template()
           query:   @collection.query
           results: @collection.toJSON()
          ))
      
    this.$('#search_query').focus()   
    @delegateEvents()  # TODO: fix    

  handleEnter: (event) ->
    if event.which == 13
      this.search event

  search: (event) ->
    @collection.query = this.$('#search_query').val()

    window.workspace.showSpinnerForView(this)
    @collection.fetch
      success: => window.workspace.hideSpinnerForView(this)
      error: =>
        window.location.hash = '!/'
        window.workspace.hideSpinnerForView(this)

    event.preventDefault()

  queueVideo: (event) ->
    window.workspace.showSpinnerForView(this)

    song_id = $(event.currentTarget).attr('data-id')
    $.post '/jukebox/songs',
      'song_id[]': [song_id]

    window.workspace.hideSpinnerForView(this)
    event.preventDefault()
