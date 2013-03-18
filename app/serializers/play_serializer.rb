class PlaySerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :skips

  # We don't want all the actual plays for this jukebox, 
  # just those currently in the queue.
  has_one :song

end
