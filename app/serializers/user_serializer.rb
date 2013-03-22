class UserSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :first_name, :last_name, :photo_url

end

