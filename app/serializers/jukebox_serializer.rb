class JukeboxSerializer < ActiveModel::Serializer
  attributes :id, :volume, :name

  # We don't want all the actual plays for this jukebox, 
  # just those currently in the queue.
  has_many :plays, key: :queue

  def plays
    object.queue
  end
end
