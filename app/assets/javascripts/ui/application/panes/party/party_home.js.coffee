#= require ui/application/panes/pane
#= require templates/party/party_home

class Warble.PartyHomeView extends Warble.PaneView
  template: window.JST['templates/party/party_home']

  events:
    'click a.button': 'toggleBrowseField'
    'click li': 'navigate'

  render: ->
    @$el.html @template
      field: @model.field
      availableField: _.without(@model.availableFields, @model.field)
    @

  toggleBrowseField: ->
    @model.field = _.without(@model.availableFields, @model.field)
    @render()

  navigate: (e) ->
    char = @$(e.target).data()['id']
    @model.char = char
    window.workspace.navigate "/party/songs/#{char}", true
