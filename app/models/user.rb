class User < ActiveRecord::Base
  validate :facebook_id, presence: true
  validate :first_name,  presence: true
  validate :last_name,   presence: true
  validate :email,       presence: true

  has_many :songs
  has_many :votes
  has_many :plays


  def self.find_or_create_by_facebook_auth(access_token)
    if user = where(facebook_id: access_token['uid']).first
      user
    else   # No user found so create one!
      info = access_token['info']
      User.create(
        first_name:  info['first_name'],
        last_name:   info['last_name'],
        email:       info['email'],
        photo_url:   info['image'],
        facebook_id: access_token['uid']
      )
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def pandora_credentials?
    pandora_username && pandora_password
  end

  def clear_pandora_credentials!
    self.pandora_username = nil
    self.pandora_password = nil
    save
  end

  def as_json(options = {})
    {
      first_name: first_name,
      last_name:  last_name,
      email:      email,
      photo_url:  photo_url
    }
  end

  def number_of_plays_today
    plays.where(created_at: Time.zone.now.midnight..(Time.zone.now.midnight + 1.day)).count
  end
end
