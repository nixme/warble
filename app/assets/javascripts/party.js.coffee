#= require handlebars.1.0.0.beta.3
#= require jquery
#= require rails/csrf
#= require underscore
#= require backbone

#= require_self

#= require models/party_songs
#= require_tree ./ui/application/panes/party

window.Warble = {}  # namespacing object for our classes

jQuery(document).ready ($) ->
  class Warble.WorkspaceRouter extends Backbone.Router
    routes:
      'party/app'                 : 'partyHome'
      'party/songs/:char'         : 'partySongs'
      '*unmatched'                : 'partyHome'

    initialize: ->
      # initialize models/collections
      @partySongs  = new Warble.PartySongList

      # initialize views
      @partyHomeView          = new Warble.PartyHomeView model: @partySongs
      @partySongsView         = new Warble.PartySongsView collection: @partySongs

      @paneEl = $('#main')
      @currentPane = null

    switchPane: (view) ->
      $(@currentView.el).remove() if @currentView
      @paneEl.append view.render().el
      view.delegateEvents()   # TODO: make this unnecessary
      view.activate?()
      @currentView = view

    partyHome: ->
      @switchPane @partyHomeView
      $('.back-button').hide()

    partySongs: (char) ->
      $('.back-button').show()
      @partySongs.query = "#{@partySongs.field}:#{char}*"
      @partySongs.fetch
        success: =>
          @switchPane @partySongsView

  window.workspace = workspace = new Warble.WorkspaceRouter
  Backbone.history.start pushState: true
