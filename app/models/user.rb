class User < Ohm::Model
  attribute :google_id
  attribute :token   # for authenticating websocket client since cookies won't pass
  attribute :first_name
  attribute :last_name
  attribute :email
  #attribute :domain
  attribute :photo_url
  attribute :pandora_username
  attribute :pandora_password

  index :google_id

  collection :songs, Song   # songs the user has added

  def validations
    assert_unique :google_id
  end

  def self.find_or_create_by_google_auth(access_token)
    if user = find(:google_id => access_token['uid']).first
      user
    else   # no user found so create one!
      user_info = access_token['user_info']
      User.create :first_name => user_info['first_name'],
                  :last_name  => user_info['last_name'],
                  :email      => user_info['email'],
                  :token      => SecureRandom.hex(10),
                  :google_id  => access_token['uid']
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def pandora_credentials?
    pandora_username && pandora_password
  end

  def pandora_client
    @pandora ||= Warble::Pandora::Client.new(pandora_username, pandora_password)
  end

  def to_hash
    super.merge :first_name => first_name,
                :last_name  => last_name,
                :email      => email,
                :photo_url  => photo_url,
  end
end
