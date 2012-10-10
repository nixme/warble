#= require ui/application/panes/pane
#= require templates/soundcloud
#= require templates/soundcloud_results
#= require templates/soundcloud_preview

# TODO: proper controller routes for pages and queries
class Warble.SoundcloudSearchView extends Warble.PaneView
  SOUNDCLOUD_CLIENT_ID = "dae39b5eb16934e43c93209cb65051ee"
  SOUNDCLOUD_SEARCH_URL = "https://api.soundcloud.com/tracks"

  template:              window.JST['templates/soundcloud']
  searchResultsTemplate: window.JST['templates/soundcloud_results']

  events:
    'click #soundlcoud_search'    : 'search'
    'keypress input'              : 'handleEnter'
    'click a.entry'               : 'queueVideo'
    'click a.scpreview'         : 'previewAudio'
    'click a#previous_results'    : 'previousPage'
    'click a#next_results'        : 'nextPage'

  initialize: ->
    @searchData = null
    @query      = ''
    @pageSize   = 10
    @startIndex = 0
    
  activate: ->
    @$('#soundcloud_query').focus()

  handleEnter: (event) ->
    if event.which == 13
      this.search event

  previewAudio: (event) ->
    console.log('play click')
    $('.scpreview').html("preview").parent('li').removeClass('show-preview')
    preview_el = @$(event.currentTarget)
    if preview_el.parent().hasClass('show-preview')
      preview_el.html 'preview'
      preview_el.parent().removeClass('show-preview')
    else
      preview_el.html window.JST['templates/soundcloud_preview']
        url: preview_el.data("soundcloud")
      preview_el.parent().addClass('show-preview')
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
    
    #reset the search start-index if it's a new search
    if @query != q
      @startIndex = 1
      @query = q
    
    search_params =
      q:            @query
      'limit':      @pageSize
      'offset':     @startIndex if @startIndex >= @pageSize
      'client_id':  SOUNDCLOUD_CLIENT_ID
      

    $.getJSON SOUNDCLOUD_SEARCH_URL, search_params, (data) =>
      # extract results into a saner object array
      @data = _.map data, (entry, index) ->
        index:          index
        soundcloud_id:  entry.id
        title:          entry.title
        thumbnail:      entry.artwork_url
        author:         entry.user.username
        url:            entry.stream_url + "?client_id=" + SOUNDCLOUD_CLIENT_ID
      
      $('#soundcloud_search_results').html @searchResultsTemplate
        results: @data
        hasPrev: @startIndex > 1
        hasNext: true #(@startIndex + data.openSearch$itemsPerPage) < data.openSearch$totalResults
    
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
