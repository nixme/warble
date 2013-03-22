class SongSerializer < ActiveModel::Serializer
  embed :ids, include: false

  attributes :id, :title, :artist, :cover_url, :url

  has_many :users_who_voted, key: :voter_ids
end

