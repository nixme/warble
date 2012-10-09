#= require ui/application/panes/pane
#= require templates/soundcloud
#= require templates/soundcloud_results

# TODO: proper controller routes for pages and queries
class Warble.SoundcloudSearchView extends Warble.PaneView
  SOUNDCLOUD_CLIENT_ID = "dae39b5eb16934e43c93209cb65051ee"
  SOUNDCLOUD_SEARCH_URL = "https://api.soundcloud.com/tracks"

  template:              window.JST['templates/soundcloud']
  searchResultsTemplate: window.JST['templates/soundcloud_results']

  events:
    'click #soundlcoud_search'    : 'search'
    'keypress input'           : 'handleEnter'
    'click a.entry'            : 'queueVideo'
    'click div.video'          : 'previewVideo'
    'click a#previous_results' : 'previousPage'
    'click a#next_results'     : 'nextPage'

  initialize: ->
    @searchData = null
    @query      = ''
    @startIndex = 1
    @pageSize   = 10

  activate: ->
    @$('#soundcloud_query').focus()

  handleEnter: (event) ->
    if event.which == 13
      this.search event

  previewVideo: (event) ->
    preview_el = @$(event.currentTarget)
    if preview_el.parent().hasClass('preview')
      preview_el.html 'preview'
      preview_el.parent().removeClass('preview')
    else
      preview_el.html window.JST['templates/youtube_preview']
        youtube_id: preview_el.data("youtube")
      preview_el.parent().addClass('preview')
    this

  previousPage: (event) ->
    @startIndex -= @pageSize + 1
    this.search event

  nextPage: (event) ->
    @startIndex += @pageSize + 1
    this.search event

  search: (event) ->
    #window.workspace.showSpinner()
    q = @$('#soundcloud_query').val()
    
    # SC.get "/tracks",
    #   q: q
    # , (tracks) ->
    #   console.log tracks
    
    #reset the search start-index if it's a new search
    if @query != q
      #@startIndex = 1
      @query = q
    
    search_params =
      q:            @query
      'limit':      @pageSize
      'client_id':  SOUNDCLOUD_CLIENT_ID

    $.getJSON SOUNDCLOUD_SEARCH_URL, search_params, (data) =>
      # extract results into a saner object array
      @data = _.map data, (entry, index) ->
       # console.log entry.title
        index:          index
        soundcloud_id:  entry.id
        title:          entry.title
        thumbnail:      entry.artwork_url
      
      $('#soundcloud_search_results').html @searchResultsTemplate
        results: @data
        #hasPrev: @startIndex > 1
        #hasNext: (@startIndex + data.feed.openSearch$itemsPerPage) < data.feed.openSearch$totalResults
    
      @$el.scrollTop 0
    #   window.workspace.hideSpinner()

    event.preventDefault()

  queueVideo: (event) ->
    # window.workspace.showSpinner()
    # 
    # $.ajax '/jukebox/playlist',
    #   type: 'POST'
    #   data:
    #     youtube: @data[$(event.currentTarget).attr('data-id')]
    #   success: =>
    #     window.workspace.hideSpinner()
    #   error: ->
    #     window.workspace.navigate '/', true
    #     window.workspace.hideSpinner()

    event.preventDefault()
