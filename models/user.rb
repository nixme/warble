class User
  include Mongoid::Document

  field :google_id
  field :first_name
  field :last_name
  field :email

  index :google_id, :unique => true

  def self.find_or_create_by_google_auth(access_token)
    if user = User.where(:google_id => access_token['uid']).first
      user
    else   # no user found so create one!
      user_info = access_token['user_info']
      User.create! :first_name => user_info['first_name'],
                   :last_name  => user_info['last_name'],
                   :email      => user_info['email'],
                   :google_id  => access_token['uid']
    end
  end
end
