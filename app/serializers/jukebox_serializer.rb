class JukeboxSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :volume, :name, :cover_photo_url

  # We don't want all the actual plays for this jukebox, 
  # just those currently in the queue.
  has_many :plays

  def plays
    object.queue
  end
end
