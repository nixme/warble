#= require ui/application/panes/pane
#= require templates/youtube
#= require templates/youtube_results
#= require templates/youtube_preview

# TODO: proper controller routes for pages and queries
class Warble.YoutubeSearchView extends Warble.PaneView
  YOUTUBE_SEARCH_URL = "http://gdata.youtube.com/feeds/api/videos?callback=?"

  template:              window.JST['templates/youtube']
  searchResultsTemplate: window.JST['templates/youtube_results']

  events:
    'click #youtube_search'    : 'search'
    'keypress input'           : 'handleEnter'
    'click a.entry'            : 'queueVideo'
    'click div.video'        : 'previewVideo'
    'click a#previous_results' : 'previousPage'
    'click a#next_results'     : 'nextPage'

  initialize: ->
    @searchData = null
    @query      = ''
    @startIndex = 1
    @pageSize   = 10

  activate: ->
    @$('#youtube_query').focus()

  handleEnter: (event) ->
    if event.which == 13
      this.search event

  previewVideo: (event) ->
    preview_el = @$(event.currentTarget)
    if preview_el.parent().hasClass('preview')
      preview_el.html 'preview'
      preview_el.parent().removeClass('preview')
    else
      preview_el.html  window.JST['templates/youtube_preview']
        youtube_id: preview_el.data("youtube")

      preview_el.parent().addClass('preview')

    @

  previousPage: (event) ->
    @startIndex -= @pageSize + 1
    this.search event

  nextPage: (event) ->
    @startIndex += @pageSize + 1
    this.search event

  search: (event) ->
    window.workspace.showSpinner()
    q = this.$('#youtube_query').val()

    # reset the search start-index if it's a new search
    if @query != q
      @startIndex = 1
      @query = q

    search_params =
      alt:           'json-in-script'
      format:        5
      'max-results': @pageSize
      'start-index': @startIndex
      q:             @query

    $.getJSON YOUTUBE_SEARCH_URL, search_params, (data) =>
      # extract results into a saner object array
      @data = _.map data.feed.entry, (entry, index) ->
        index:      index
        youtube_id: entry.id.$t.substring(entry.id.$t.lastIndexOf('/') + 1)
        title:      entry.title.$t
        author:     entry.author[0].name.$t
        thumbnail:  entry.media$group.media$thumbnail[0].url

      $('#youtube_search_results').html @searchResultsTemplate
        results: @data
        hasPrev: @startIndex > 1
        hasNext: (@startIndex + data.feed.openSearch$itemsPerPage.$t) < data.feed.openSearch$totalResults.$t

      $(@el).scrollTop 0
      window.workspace.hideSpinner()

    event.preventDefault()

  queueVideo: (event) ->
    window.workspace.showSpinner()

    $.ajax '/jukebox/playlist',
      type: 'POST'
      data:
        youtube: @data[$(event.currentTarget).attr('data-id')]
      success: =>
        window.workspace.hideSpinner()
      error: ->
        window.workspace.navigate '/', true
        window.workspace.hideSpinner()

    event.preventDefault()
