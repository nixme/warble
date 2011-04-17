class HypeFeedsView extends Backbone.View
  template: -> window.templates['hype_feeds']

  events:
    'click #username_search' : 'usernameSearch'
    'keypress input'         : 'handleEnter'

  initialize: ->
    _.bindAll this, 'render', 'usernameSearch', 'handleEnter'
    @el = $('#add .content')

  render: ->
    $(@el).html @template()
    this.delegateEvents() # TODO: fix
    this

  usernameSearch: (event) ->
    username = this.$('#username_query').val()
    window.location.hash = "#!/hype/#{username}/1"
    event.preventDefault()
