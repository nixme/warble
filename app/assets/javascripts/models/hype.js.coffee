# TODO: can't a single Song class deal with this and pandora song since they're
#       the same on the server?
class Warble.HypeSong extends Backbone.Model

class Warble.HypeSongList extends Backbone.Collection
  model: Warble.HypeSong
