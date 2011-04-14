# TODO: can't a single Song class deal with this and pandora song since they're
#       the same on the server?
class HypeSong extends Backbone.Model

class HypeSongList extends Backbone.Collection
  model: HypeSong
