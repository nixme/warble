class User < ActiveRecord::Base
 devise :token_authenticatable, :omniauthable, :trackable, :rememberable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation,
    :remember_me, :first_name, :last_name, :photo_url, :email

  validate :first_name,  presence: true
  validate :last_name,   presence: true
  validate :email,       presence: true
  
  has_many :identites
  has_many :songs
  has_many :votes
  has_many :plays


  def self.create_with_omniauth(info)
     # GitHub doesn't return these fields individually.
     unless first_name = info['first_name'] && last_name = info['last_name']
       first_name, last_name = info['name'].split(" ")
     end

     create(first_name: first_name,
           last_name:   last_name,
           email:       info['email'],
           photo_url:   info['image'])
  end

  def self.find_or_create_by_email_with_omniauth(info)
    where(email: info['email']).first || create_with_omniauth(info)
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
