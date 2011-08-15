#= require templates/youtube
#= require templates/youtube_results

# TODO: proper controller routes for pages and queries
class Warble.YoutubeSearchView extends Backbone.View
  YOUTUBE_SEARCH_URL = "http://gdata.youtube.com/feeds/api/videos?callback=?"

  template:              -> window.JST['templates/youtube']
  searchResultsTemplate: -> window.JST['templates/youtube_results']

  events:
    'click #youtube_search'    : 'search'
    'keypress input'           : 'handleEnter'
    'click a.entry'            : 'queueVideo'
    'click a#previous_results' : 'previousPage'
    'click a#next_results'     : 'nextPage'

  initialize: ->
    _.bindAll this, 'render', 'search', 'handleEnter', 'queueVideo'
    @el = $('#add')

    @searchData = null
    @query      = ''
    @startIndex = 1
    @pageSize   = 10

  render: ->
    $(@el).html @template()
    this.$('#youtube_query').focus()
    this.delegateEvents()  # TODO: fix

  handleEnter: (event) ->
    if event.which == 13
      this.search event

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

      $('#youtube_search_results').html @searchResultsTemplate()
        results: @data
        hasPrev: @startIndex > 1
        hasNext: (@startIndex + data.feed.openSearch$itemsPerPage.$t) < data.feed.openSearch$totalResults.$t

      $(@el).scrollTop 0
      window.workspace.hideSpinner()

    event.preventDefault()

  queueVideo: (event) ->
    window.workspace.showSpinner()

    $.ajax '/jukebox/songs',
      type: 'POST'
      data:
        youtube: @data[$(event.currentTarget).attr('data-id')]
      success: =>
        window.workspace.hideSpinner()
      error: ->
        window.location.hash = '!/'
        window.workspace.hideSpinner()

    event.preventDefault()
