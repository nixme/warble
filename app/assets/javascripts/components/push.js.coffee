# Encapsulate the Faye client to the push server. Exposes pushed messages via
# bindable events.
#
# This component needs to be initialized. Expects `window.base_url` to be
# defined.
#
Warble.push = _.extend {}, Backbone.Events,
  initialize: ->
    # Add cross-origin-long-polling to avoid using callback-polling, even for
    # the handshake phase.
    Faye.MANDATORY_CONNECTION_TYPES =
      ['long-polling', 'cross-origin-long-polling',
       'callback-polling', 'in-process']

    @_client = new Faye.Client "http://#{window.base_url}:9292/",
      timeout: 30
      retry:   15

    # Bubble some Faye events.
    @_client.bind 'transport:up',   => @trigger 'transport:up'
    @_client.bind 'transport:down', => @trigger 'transport:down'

    _.defer => @_subscribe()    # Avoid browser spinner by ticking event loop.

  _subscribe: ->
    # Cleanup existing subscriptions to prevent multiple callbacks.
    unless _.isEmpty @_client._channels.getKeys()
      @_client.unsubscribe '/global', @_receive, this

    @_client.subscribe '/global', @_receive, this

  _receive: (message) ->
    switch message.event
      when 'reload' then window.location.reload(true)
      else @trigger(message.event, message)
