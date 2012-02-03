class Song < ActiveRecord::Base
  validate :source,      presence: true
  validate :external_id, presence: true
  validate :title,       presence: true

  belongs_to :user
  has_many   :votes
  has_many   :plays
  has_many   :users_who_voted,  through: :votes, source: :user
  has_many   :users_who_played, through: :plays, source: :user


  # TODO: search indexing stuff

  def as_json(options = {})
    {
      source:      source,
      title:       title,
      artist:      artist,
      album:       album,
      cover_url:   cover_url,
      url:         url,
      external_id: external_id,
      user:        user
      # TODO: add collection of likes
    }
  end
end
