# Clones the position of one element to another.
# This is a port of Prototypes's Element.clonePosition.
# See: http://api.prototypejs.org/dom/Element/clonePosition
window.Utils = Utils ? {}
Utils.clonePosition = (src, target, options = {}) ->
  _.defaults options,
    setWidth: true
    setHeight: true
    offsetLeft: 0
    offsetTop: 0

  offsets = $(src).offset()

  $(target).css {
    position: 'absolute'
    top: "#{offsets.top + options.offsetTop}px"
    left: "#{offsets.left + options.offsetLeft}px"
  }

  if options.setWidth
    $(target).width $(src).width()

  if options.setHeight
    $(target).height $(src).height()

  true
